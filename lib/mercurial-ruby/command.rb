require 'timeout'
require 'digest/md5'

module Mercurial
  class CommandError < Error; end
  
  class Command
    attr_accessor :command, :repository
    
    def initialize(cmd, options={})
      @command = cmd
      @repository = options[:repository]
    end

    def execute
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
      raise_exception_for_stderr(error)
      result
    end
    
  private
  
    def execution_timeout
      Mercurial.configuration.shell_timeout
    end
    
    def raise_exception_for_stderr(error)
      if error && error != ''
        raise CommandError, error
      end
    end
    
    def cache_key
      "hg.#{ repository.mtime }." + Digest::MD5.hexdigest(command)
    end
    
  end
  
end