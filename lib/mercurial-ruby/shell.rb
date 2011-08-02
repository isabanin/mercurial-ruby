module Mercurial
  
  module Shell
    extend self
    
    def binary_path
      Mercurial.configuration.hg_binary_path
    end
    
    def run(cmd, options={})
      build = []
      if options[:in]
        build << "cd #{ options[:in] }"
      end
      build << cmd
      to_run = build.join('&&')
      `#{ to_run }`
    end
    
    def hg(cmd, options={})
      run("#{ binary_path } #{ cmd }", options)
    end
    
  end
  
end