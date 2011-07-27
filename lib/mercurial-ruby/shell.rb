module Mercurial
  
  module Shell
    extend self
    
    def binary_path
      'hg'
    end
    
    def run(cmd, options={})
      build = []
      if options[:in]
        build << "cd #{ options[:in] }"
      end
      build << cmd
      `#{ build.join('&&') }`
    end
    
    def hg(cmd, options={})
      run("#{ binary_path } #{ cmd }", options)
    end
    
  end
  
end