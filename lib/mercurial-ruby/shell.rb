module Mercurial
  
  class Shell
    
    attr_reader :repository
    
    def self.run(cmd, options={})
      options[:cache] ||= true
      build = []
      if options[:in]
        build << "cd #{ options[:in] }"
      end
      build << cmd
      to_run = build.join(' && ')
      Mercurial::Command.new(to_run, :repository => options[:repository], :cache => options[:cache]).execute
    end
    
    def initialize(repository)
      @repository = repository
    end
    
    def hg(cmd, options={})
      options[:in] ||= repository.path
      options[:repository] = repository
      run("#{ hg_binary_path } #{ cmd }", options)
    end
    
    def run(cmd, options={})
      self.class.run(cmd, options)
    end
    
  private
  
    def hg_binary_path
      Mercurial.configuration.hg_binary_path
    end
    
  end
  
end