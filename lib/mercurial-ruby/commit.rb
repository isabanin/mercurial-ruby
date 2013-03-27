module Mercurial
  
  #
  # The class represents Mercurial changeset. Obtained by running an +hg log+ command.
  # Contains a lot of information, including commit's ID, author name, email, list of changed files, etc.
  #
  # The class represents Commit object itself, {Mercurial::CommitFactory CommitFactory} is responsible
  # for assembling instances of Commit. For the list of all possible commit-related operations 
  # check {Mercurial::CommitFactory CommitFactory}.
  #
  # For general information on Mercurial commits:
  #
  # http://mercurial.selenic.com/wiki/Commit
  #
  class Commit
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    # Mercurial changeset ID. 40-chars long SHA1 hash.
    attr_reader :hash_id
    
    # Name of the user committed the change.
    attr_reader :author
    
    # Email of the user committed the change.
    attr_reader :author_email
    
    # Exact date and time of the commit. Contains Ruby Time object.
    attr_reader :date
    
    # Full commit message, with line breaks and other stuff.
    attr_reader :message
    
    # Array of {Mercurial::ChangedFile ChangedFile} objects.
    attr_reader :changed_files
    
    # Name of a branch associated with the commit.
    attr_reader :branch_name
    
    # Array of commit's tags.
    attr_reader :tags_names
    
    # Array of commit's parents.
    attr_reader :parents_ids
    
    alias :id :hash_id
    
    def initialize(repository, opts={}) #:nodoc:
      @repository     = repository
      @hash_id        = opts[:hash_id]
      @author         = opts[:author]
      @author_email   = opts[:author_email]
      @date           = Time.iso8601(opts[:date])
      @message        = opts[:message]
      @changed_files  = files_to_array(opts[:changed_files])
      @branch_name    = opts[:branch_name]
      @tags_names     = tags_to_array(opts[:tags_names])
      @parents_ids    = parents_to_array(opts[:parents])
    end
    
    def merge?
      parents.size > 1
    end
    
    def blank?
      hash_id == '0'*40
    end
    
    def diffs(cmd_options={})
      repository.diffs.for_commit(self, cmd_options)
    end
    
    def parents
      repository.commits.by_hash_ids(parents_ids)
    end

    def trivial_parents_ids
      hg(["parents -r ? --template '{node}\n'", hash_id]).split("\n")
    end

    def ancestors
      repository.commits.ancestors_of(hash_id)
    end
    
    def parent_id
      parents_ids.first
    end
    
    def exist_in_branches
      repository.branches.for_commit(hash_id)
    end

    def short_hash_id
      hash_id.to_s[0,12]
    end

    #
    # Returns a Hash of diffstat-style summary of changes for the commit.
    #
    def stats(cmd_options={})
      raw = hg(["log -r ? --stat --template '{node}\n'", hash_id], cmd_options)
      result = raw.scan(/(\d+) files changed, (\d+) insertions\(\+\), (\d+) deletions\(\-\)$/).flatten.map{|r| r.to_i}
      return {} if result.empty? # that commit has no stats
      {
        'files'     => result[0],
        'additions' => result[1],
        'deletions' => result[2],
        'total'     => result[1] + result[2]
      }
    end
    
    def to_hash
      {
        'id'       => hash_id,
        'parents'  => parents_ids,
        'branch'   => branch_name,
        'tags'     => tags_names,
        'message'  => message,
        'date'     => date,
        'author'   => {
          'name'  => author,
          'email' => author_email
        }
      }
    end
    
  protected
  
    def files_to_array(array)
      [].tap do |returning|
        array.each do |files|
          if files
            files.split(';').map do |file_with_mode|
              returning << Mercurial::ChangedFileFactory.new_from_hg(file_with_mode)
            end
          end
        end
        
        remove_files_duplicates(returning)
      end
    end
    
    def remove_files_duplicates(files)
      Mercurial::ChangedFileFactory.delete_hg_artefacts(files)
    end
    
    def tags_to_array(tags_str)
      string_to_array(tags_str) do |returning|
        returning << tags_str
      end
    end
    
    def parents_to_array(string)
      string_to_array(string) do |returning|
        string.split(' ').map do |hg_hash|
          returning << hg_hash_to_hash_id(hg_hash)
        end
      end
    end
    
    def string_to_array(string, &block)
      if string && !string.empty?
        [].tap do |returning|
          block.call(returning)
        end
      else
        []
      end
    end
    
    def hg_hash_to_hash_id(hg_hash)
      hg_hash.split(':').last
    end
    
  end
  
end
