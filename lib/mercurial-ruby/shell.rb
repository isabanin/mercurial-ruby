module Mercurial
  
  class Shell
    
    attr_reader :repository
    
    def self.run(cmd, options={})
      build = []

      if options[:append_hg]
        cmd = append_command_with(hg_binary_path, cmd)
      end

      if dir = options.delete(:in)
        build << "cd #{ dir }"
      end
      
      if cmd.kind_of?(Array)
        cmd = interpolate_arguments(cmd)
      end

      build << cmd
      to_run = build.join(' && ')

      if pipe_cmd = options[:pipe]
        to_run << " | #{ pipe_cmd }"
      end

      Mercurial::Command.new(to_run, options).execute
    end
    
    def initialize(repository)
      @repository = repository
    end
    
    def hg(cmd, options={})
      options[:in] ||= repository.path
      options[:repository] = repository
      options[:append_hg] = true
      run(cmd, options)
    end
    
    def run(cmd, options={})
      self.class.run(cmd, options)
    end
    
  private
  
    def self.hg_binary_path
      Mercurial.configuration.hg_binary_path
    end
    
    def self.interpolate_arguments(cmd_with_args)
      cmd_with_args.shift.tap do |cmd|
        cmd.gsub!(/\?/) do
          cmd_with_args.shift.to_s.enclose_in_single_quotes
        end
      end
    end
    
    def self.append_command_with(append, cmd)
      if cmd.kind_of?(Array)
        cmd[0].insert(0, "#{ append } ")
        cmd
      else
        "#{ append } #{ cmd }"
      end
    end
    
  end
  
end
