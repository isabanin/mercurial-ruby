require 'timeout'

module Mercurial
  class CommandError < Error; end
  
  class Command
    attr_accessor :pid, :status, :command, :options
    
    def initialize(cmd, options={})
      @command = cmd
      @options = options
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
    
  end
  
end