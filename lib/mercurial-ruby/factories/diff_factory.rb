module Mercurial
  
  class DiffFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def for_commit(commit)
      [].tap do |returning|
        commit.files_changed.each do |file|
          data = hg("diff -r#{ commit.parent_id } -r#{ commit.hash_id } \"#{ file.first }\"")
          returning << build(commit, data)
        end
      end
    end
    
  private
  
    def build(commit, data)
      return if data.empty?
      hash_a, hash_b = *data.scan(/^diff -r (\w+) -r (\w+)/).first
      file_a = data.scan(/^--- a\/(.+)\t/).flatten.first
      file_b = data.scan(/^\+\+\+ b\/(.+)\t/).flatten.first
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