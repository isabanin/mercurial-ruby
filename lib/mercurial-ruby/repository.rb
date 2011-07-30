module Mercurial
  
  class Repository
    
    attr_reader :path
    
    def self.create(destination)
      init_repository(destination)      
      open(destination)
    end
    
    def self.open(destination)
      if File.exists?(destination)
        new(destination)
      else
        raise Mercurial::RepositoryNotFound.new(destination)
      end
    end
    
    def initialize(source)
      @path = source
    end
    
    def config
      @_config ||= Mercurial::ConfigFile.new(self)
    end
    
    def hooks
      @_hook_factory ||= Mercurial::HookFactory.new(self)
    end
    
    def commits
      @_commits ||= Mercurial::CommitFactory.new(self)
    end
    
    def branches
      @_branches ||= Mercurial::BranchFactory.new(self)
    end
    
    def tags
      @_tags ||= Mercurial::TagFactory.new(self)
    end
    
    def diffs
      @_diffs ||= Mercurial::DiffFactory.new(self)
    end
    
    def destroy!
      FileUtils.rm_rf(path)
    end
    
  protected
  
    def self.init_repository(destination)
      Mercurial::Shell.run("mkdir -p #{ destination }")
      Mercurial::Shell.hg('init', :in => destination)
      Mercurial::Shell.hg('update null', :in => destination)
    end
    
  end
  
end