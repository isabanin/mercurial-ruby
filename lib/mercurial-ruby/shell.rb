module Mercurial
  
  module Shell
    extend self
    
    def binary_path
      Mercurial.configuration.hg_binary_path
    end
    
    def hg(cmd, options={})
      run("#{ binary_path } #{ cmd }", options)
    end
    
    def run(cmd, options={})
      build = []
      if options[:in]
        build << "cd #{ options[:in] }"
      end
      build << cmd
      to_run = build.join('&&')
      Mercurial::Command.new(to_run).execute
    end
    
  end
  
end