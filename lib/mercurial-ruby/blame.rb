module Mercurial
  
  class Blame
    
    attr_reader :repository
    attr_reader :contents
    
    def initialize(repository, data)
      @repository = repository
      @contents = data
    end
    
  end
  
end