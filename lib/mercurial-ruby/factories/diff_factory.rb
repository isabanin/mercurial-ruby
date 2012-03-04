module Mercurial
  
  #
  # This class represents a factory for {Mercurial::Diff Diff} instances.
  #
  class DiffFactory
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    # Returns an array of {Mercurial::Diff Diff} instances for a specified
    # instance of {Mercurial::Commit Commit}. Represents changeset's diffs.
    #
    # === Example:
    #  commit = repository.commits.by_hash_id('291a498f04e9')
    #  repository.diffs.for_commit(commit)
    #
    def for_commit(commit, cmd_options={})
      [].tap do |returning|
        data = hg(["diff -c ?", commit.hash_id], cmd_options)
        chunks = data.split(/^diff/)[1..-1]
        unless chunks.nil?
          chunks.map do |piece| 
            piece = "diff" << piece
            returning << build(piece)
          end
        end
      end
    end
    
    def for_path(path, revision_a, revision_b, options={}, cmd_options={})
      cmd = "diff ? -r ? -r ?"
      cmd << ' -w' if options[:ignore_whitespace]
      build(hg([cmd, path, revision_a, revision_b], cmd_options))
    end
    
  private
  
    def build(data)
      return if data.empty?      
      hash_a, hash_b = *data.scan(/^diff -r (\w+) -r (\w+)/).first

      if binary_file = data.scan(/^Binary file (.+) has changed/).flatten.first
        file_a = binary_file
        body = 'Binary files differ'
      else
        file_a = data.scan(/^\[?--- (?:a\/([^\+]+)|\/dev\/null)-?\]?\t/).flatten.first
        file_b = data.scan(/^\{?\+\+\+ (?:b\/([^\+]+)|\/dev\/null)\+?\}?\t/).flatten.first
        body = data[data.index("\n")+1..-1]
      end

      Mercurial::Diff.new(
        :hash_a => hash_a,
        :hash_b => hash_b,
        :file_a => file_a,
        :file_b => file_b,
        :body   => body,
        :binary => !!binary_file
      )
    end
    
  end
  
end
