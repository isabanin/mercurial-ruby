module Mercurial
  
  #
  # Use this class to setup various internal settings of the gem.
  #
  # Example:
  #
  #  Mercurial.configure do |conf|
  #   conf.cache_store = Rails.cache
  #   conf.debug_mode = true
  #  end
  #
  # Currently only the following settings are supported:
  #
  # * hg_binary_path — path to hg binary in your system. Default is /usr/local/bin/hg.
  # * shell_timeout — default execution timeout for all hg shell commands. Default is 3000.
  # * cache_store — Rails's CacheStore compatible class for caching results of successful hg commands. Default is nil.
  # * debug_mode — send all hg commands to stdout before execution. Default is false.
  #  
  class Configuration
    
    attr_accessor :hg_binary_path, :shell_timeout, :cache_store, :debug_mode
    
    def initialize
      @hg_binary_path = '/usr/local/bin/hg'
      @shell_timeout  = 3000
      @debug_mode     = false
    end
    
  end
  
end
