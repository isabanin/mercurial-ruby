module Mercurial
  
  class HookFactory
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      [].tap do |returning|
        repository.config.find_header('hooks').each_pair do |name, value|
          returning << build(name, value)
        end
      end
    end
    
    def by_name(name)
      all.find do |h|
        h.name == name
      end
    end
    
    def create(name, value)
      build(name, value).tap do |hook|
        hook.save
      end
    end
    
    def destroy!(name)
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