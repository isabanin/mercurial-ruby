module Mercurial
  
  class DiffFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def for_commit(commit)
      [].tap do |returning|
        data = hg("diff -c#{ commit.hash_id }")
        chunks = data.split(/^diff/)[1..-1]
        unless chunks.nil?
          chunks.map do |piece| 
            piece = "diff" << piece
            returning << build(commit, piece)
          end
        end
      end
    end
    
  private
  
    def build(commit, data)
      return if data.empty?      
      hash_a, hash_b = *data.scan(/^diff -r (\w+) -r (\w+)/).first

      if binary_file = data.scan(/^Binary file (.+) has changed/).flatten.first
        file_a = binary_file
        body = 'Binary files differ'
      else
        file_a = data.scan(/^--- (?:a\/(.+)|\/dev\/null)\t/).flatten.first
        file_b = data.scan(/^\+\+\+ (?:b\/(.+)|\/dev\/null)\t/).flatten.first
        body = data[data.index("\n")+1..-1]
      end

      Mercurial::Diff.new(commit,
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