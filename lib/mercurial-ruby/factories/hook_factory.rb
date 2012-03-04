module Mercurial
  
  #
  # This class is a handy way to manage hooks in your repository.
  #
  class HookFactory
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    #
    # Finds all repository hooks. Returns an array of {Mercurial::Hook Hook} instances.
    #
    # === Example:
    #  repository.hooks.all
    #
    def all
      [].tap do |returning|
        repository.config.find_header('hooks').each_pair do |name, value|
          returning << build(name, value)
        end
      end
    end
    
    #
    # Finds a specific hook by it's name. Returns an instance of {Mercurial::Hook Hook}.
    #
    # === Example:
    #  repository.hooks.by_name('changegroup')
    #
    def by_name(name)
      all.find do |h|
        h.name == name.to_s
      end
    end
    
    #
    # Adds a new hook to the repository.
    #
    # === Example:
    #  repository.hooks.add('changegroup', 'do_something')
    #
    def add(name, value)
      build(name, value).tap do |hook|
        hook.save
      end
    end
    
    #
    # Removes a hook from the repository.
    #
    # === Example:
    #  repository.hooks.remove('changegroup')
    #
    def remove(name)
      if hook = by_name(name)
        hook.destroy!
      end
    end
    
  protected
  
    def build(name, value)
      Mercurial::Hook.new(repository, name, value)
    end
    
  end
  
end
