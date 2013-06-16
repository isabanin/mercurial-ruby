module Mercurial

  #
  # This class was ported from grit.
  #
  # It implements a file-based 'file index', a simple index of
  # all of the reachable commits in a repo, along with the parents
  # and which files were modified during each commit.
  #
  # This class creates and reads a file named '[.hg]/file-index'.
  #
  class FileIndex
    include Mercurial::Helper

    class IndexFileNotFound < StandardError;end
    class IndexFileTooBig < StandardError;end
    class UnsupportedRef < StandardError;end

    class << self
      attr_accessor :max_file_size
    end

    self.max_file_size = 10_000_000 # ~10M

    attr_reader :repository

    # initializes index given repository
    def initialize(repository)
      @repository = repository      
    end
    
    def reload
      @_read_complete = false
    end
    
    # updates file index
    def update(oldrev=nil, newrev=nil)
      if index_file_exists? && oldrev != "0"*40
        hg([
            "log --debug -r ?:? --style ? >> ?",
            oldrev, newrev, Style.file_index, path
          ])
      else
        hg(["log --debug -r : --style ? > ?", Style.file_index, path])
      end
    end

    # returns count of all commits
    def count_all
      read_if_needed
      @sha_count
    end

    # returns count of all commits reachable from SHA
    # note: originally did this recursively, but ruby gets pissed about that on
    # really big repos where the stack level gets 'too deep' (thats what she said)
    def count(commit_sha)
      read_if_needed
      commits_from(commit_sha).size
    end

    # builds a list of all commits reachable from a single commit
    def commits_from(commit_sha)
      raise UnsupportedRef if commit_sha.is_a? Array
      read_if_needed

      already = {}
      final = []
      left_to_do = [commit_sha]

      while commit_sha = left_to_do.shift
        next if already[commit_sha]

        final << commit_sha
        already[commit_sha] = true

        commit = @commit_index[commit_sha]
        commit[:parents].each do |sha|
          left_to_do << sha
        end if commit
      end

      sort_commits(final)
    end

    # returns files changed at commit sha
    def files(commit_sha)
      read_if_needed
      if commit = @commit_index[commit_sha]
        commit[:files]
      else
        []
      end
    end

    # returns all commits for a file
    def commits_for(file)
      read_if_needed
      @all_files[file] || []
    end

    # returns the shas of the last commits for all
    # the files in [] from commit_sha
    # files_matcher can be a regexp or an array
    def last_commits(commit_sha, files_matcher)
      read_if_needed
      acceptable = commits_from(commit_sha)

      matches = {}

      if files_matcher.is_a? Regexp
        files = @all_files.keys.select { |file| file =~ files_matcher }
        files_matcher = files
      end

      if files_matcher.is_a? Array
        # find the last commit for each file in the array
        files_matcher.each do |f|
          @all_files[f].each do |try|
            if acceptable.include?(try)
              matches[f] = try
              break
            end
          end if @all_files[f]
        end
      end

      matches
    end
    
    def destroy!
      FileUtils.rm_f(path)
    end
    
    def path
      File.join(repository.dothg_path, 'file-index')
    end

  private
    
    def index_file_exists?
      FileTest.exists?(path)
    end
    
    def index_file_valid?
      File.file?(path) && (File.size(path) < Mercurial::FileIndex.max_file_size)
    end
    
    def sort_commits(sha_array)
      read_if_needed
      sha_array.sort { |a, b| @commit_order[b].to_i <=> @commit_order[a].to_i }
    end
    
    def read_if_needed
      if @_read_complete
        true
      else
        begin
          read_index
        rescue IndexFileNotFound => e
          if @_tried_updating
            raise e
          else
            @_tried_updating = true
            update
            retry
          end
        end
      end
    end
    
    def validate_index_file
      if File.file?(path)
        if File.size(path) > Mercurial::FileIndex.max_file_size
          raise IndexFileTooBig, "#{ path } is bigger than #{ Mercurial::FileIndex.max_file_size }"
        end
      else
        raise IndexFileNotFound, path unless index_file_valid?
      end      
    end

    def read_index
      validate_index_file      
      f = File.new(path, 'rb')
      @sha_count = 0
      @commit_index = {}
      @commit_order = {}
      @all_files = {}
      while line = f.gets
        if /^(\w{40})/.match(line)
          shas = line.scan(/(\w{40})/)
          current_sha = shas.shift.first
          parents = shas.map { |sha| sha.first }
          parents = parents.delete_if { |sha| sha == '0'*40 }
          @commit_index[current_sha] = {:files => [], :parents => parents }
          @commit_order[current_sha] = @sha_count
          @sha_count += 1
        else
          file_name = line.chomp
          unless file_name.empty?
            tree = ''
            File.dirname(file_name).split('/').each do |part|
              next if part == '.'
              tree += part + '/'
              @all_files[tree] ||= []
              @all_files[tree].unshift(current_sha)
            end
            @all_files[file_name] ||= []
            @all_files[file_name].unshift(current_sha)
            @commit_index[current_sha][:files] << file_name
          end
        end
      end
      @_read_complete = true
    end

  end
end
