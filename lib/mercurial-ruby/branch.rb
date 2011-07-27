module Mercurial
  
  class Branch
    
    attr_reader :repository, :name, :status, :latest_commit
    
    def initialize(repository, name, options={})
      @repository    = repository
      @name          = name
      @status        = options[:status] == 'closed' ? 'closed' : 'active'
      @latest_commit = options[:commit]
    end
    
    def active?
      status == 'active'
    end
    
    def closed?
      status == 'closed'
    end
    
  end
  
end