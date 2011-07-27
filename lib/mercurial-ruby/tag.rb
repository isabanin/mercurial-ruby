module Mercurial
  
  class Tag
    
    attr_reader :repository, :name, :hash_id
    
    def initialize(repository, name, hash_id)
      @repository = repository
      @name       = name
      @hash_id    = hash_id
    end
    
  end
  
end