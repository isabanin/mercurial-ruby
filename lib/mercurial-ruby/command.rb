require 'timeout'
require 'digest/md5'
if ENV['OS'] == 'Windows_NT'
  require 'open3'
else
  require 'open4'
end

module Mercurial
  class CommandError < Error; end
  
  #
  # This class represents a shell command. You probably don't want to deal with this yourself, 
  # use the {Mercurial::Shell Shell} class instead.
  #
  class Command
    attr_accessor :command, :repository, :use_cache, :timeout
    
    def initialize(cmd, options={})
      @command    = cmd
      @repository = options[:repository]
      @use_cache  = options[:cache].nil? || options[:cache] == false ? false : true
      @timeout    = options[:timeout] ? options[:timeout].to_i : global_execution_timeout.to_i
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
      repository && !repository.cache_disabled_by_override? && cache_store && use_cache
    end
    
    def cache_store
      Mercurial.configuration.cache_store
    end
  
    def global_execution_timeout
      Mercurial.configuration.shell_timeout
    end
    
    def execute_with_caching
      cache_store.fetch(cache_key, &execution_proc)
    end
    
    def execute_without_caching
      execution_proc.call
    end

    def read_output_error (stdout, stderr, timeout)
      result, error = '', ''
      Timeout.timeout(timeout) do
        while tmp = stdout.read(102400)
          result += tmp
        end
      end

      while tmp = stderr.read(1024)
        error += tmp
      end
      return result, error
    end
    
    def execution_proc
      Proc.new do
        debug(command)
        result, error, = '', ''
        exitstatus = -1
        if ENV['OS'] == 'Windows_NT'
          # popen4 uses fork, need popen3 here
          Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
            result, error = read_output_error(stdout, stderr, timeout)
            exitstatus = if RUBY_VERSION =~ /^1\.8/
                           error.empty? ? 0 : 1
                         else
                           wait_thread.value.exitstatus
                         end
          end
        else
          exitstatus = Open4.popen4(command) do |pid, stdin, stdout, stderr|
            result, error = read_output_error(stdout, stderr, timeout)
          end.exitstatus
        end
        raise_error_if_needed(exitstatus, error)
        result
      end
    end
    
    def raise_error_if_needed(exitstatus, error)
      return if exitstatus == 0
      if error && error != ''
        raise CommandError, error
      end
    end
    
    def cache_key
      "hg.#{ repository.mtime }." + Digest::MD5.hexdigest(command)
    end

    def debug(msg)
      if Mercurial.configuration.debug_mode
        puts msg
      end
    end
    
  end
  
end
