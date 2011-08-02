module Mercurial
  
  class Configuration
    
    attr_accessor :hg_binary_path
    
    def initialize
      @hg_binary_path = '/usr/local/bin/hg'
    end
    
  end
  
end