module Mercurial
  
  class Hook
    
    attr_reader :repository, :name, :value
    
    def initialize(repository, name, value)
      @repository = repository
      @name = name
      @value = value
    end
    
    def save
      repository.config.add_setting('hooks', name, value)
    end
    
    def destroy!
      repository.config.delete_setting!('hooks', name)
    end
    
  end
  
end