module Mercurial  
  
  class Command
    attr_accessor :pid, :status, :command, :options
    
    def initialize(cmd, options={})
      @command = cmd
      @options = options
    end

    def execute
      `#{command}`
    end
    
  end
  
end