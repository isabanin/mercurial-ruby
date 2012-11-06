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
  # Only the following settings are supported:
  #
  # * hg_binary_path — path to hg binary in your system. Defaults to /usr/local/bin/hg.
  # * shell_timeout — default execution timeout for all hg shell commands. Defaults to 3000.
  # * cache_store — Rails's CacheStore compatible class for caching results of successful hg commands. Defaults to nil.
  # * debug_mode — send all hg commands to stdout before execution. Defaults to false.
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
