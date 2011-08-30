require 'timeout'
require 'digest/md5'

module Mercurial
  class CommandError < Error; end
  
  class Command
    attr_accessor :command, :repository, :use_cache
    
    def initialize(cmd, options={})
      @command    = cmd
      @repository = options[:repository]
      @use_cache  = options[:cache]
    end

    def execute
      if cache_commands?
        execute_with_caching
      else
        execute_without_caching
      end      
    end
    
  private
  
    def cache_commands?
      repository && use_cache && cache_store
    end
    
    def cache_store
      Mercurial.configuration.cache_store
    end
  
    def execution_timeout
      Mercurial.configuration.shell_timeout
    end
    
    def execute_with_caching
      cache_store.fetch(cache_key, &execution_proc)
    end
    
    def execute_without_caching
      execution_proc.call
    end
    
    def execution_proc
      Proc.new do
        result, error = '', ''
        Open3.popen3(command) do |_, stdout, stderr|
          Timeout.timeout(execution_timeout) do
            while tmp = stdout.read(102400)
              result += tmp
            end
          end

          while tmp = stderr.read(1024)
            error += tmp
          end
        end
        raise_error_if_needed(error)
        result
      end
    end
    
    def raise_error_if_needed(error)
      if error && error != ''
        raise CommandError, error
      end
    end
    
    def cache_key
      "hg.#{ repository.mtime }." + Digest::MD5.hexdigest(command)
    end
    
  end
  
end