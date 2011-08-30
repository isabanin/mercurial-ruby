module Mercurial
  
  class Configuration
    
    attr_accessor :hg_binary_path, :shell_timeout, :cache_store
    
    def initialize
      @hg_binary_path = '/usr/local/bin/hg'
      @shell_timeout  = 3000
    end
    
  end
  
end