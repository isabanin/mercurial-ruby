module Mercurial
  
  class Configuration
    
    attr_accessor :hg_binary_path, :shell_timeout, :cache_store, :debug_mode
    
    def initialize
      @hg_binary_path = '/usr/local/bin/hg'
      @shell_timeout  = 3000
      @debug_mode     = false
    end
    
  end
  
end
