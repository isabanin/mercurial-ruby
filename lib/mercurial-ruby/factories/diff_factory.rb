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
        data.split(/^diff/)[1..-1].map do |piece| 
          piece = "diff" << piece
          returning << build(commit, piece)
        end
      end
    end
    
  private
  
    def build(commit, data)
      return if data.empty?      
      hash_a, hash_b = *data.scan(/^diff -r (\w+) -r (\w+)/).first
      file_a = data.scan(/^--- (?:a\/(.+)|\/dev\/null)\t/).flatten.first
      file_b = data.scan(/^\+\+\+ (?:b\/(.+)|\/dev\/null)\t/).flatten.first
      body = data[data.index("\n")+1..-1]
      Mercurial::Diff.new(commit,
        :hash_a => hash_a,
        :hash_b => hash_b,
        :file_a => file_a,
        :file_b => file_b,
        :body   => body
      )
    end
    
  end
  
end