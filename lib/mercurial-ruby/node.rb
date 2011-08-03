module Mercurial
  
  class Node
    
    attr_reader :repository, :name, :hash_id
    
    def initialize(repository, name, hash_id)
      @repostiory = repostiory
      @name = name
      @hash_id = hash_id
    end
    
    def revision
    end
    
    def entries
    end
    
    def directory?
    end
    
    def file?
    end
    
  end
  
end