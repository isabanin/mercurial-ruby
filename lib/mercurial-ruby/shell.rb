module Mercurial
  
  #
  # This is a tiny helper class that makes it simple for you to execute shell commands.
  # Use it to execute hg commands that don't have a proper wrappers yet. 
  #
  class Shell
    
    attr_reader :repository
    
    #
    # Creates a {Mercurial::Command Command} instance and executes it. Supports a few neat options:
    #
    # ==== :append_hg
    #
    # You don't have to worry about specifying a correct path to your hg binary every time you want to execute a command:
    #
    #   Shell.run("help", :append_hg => true)
    #
    # ==== Arguments interpolation
    #
    # Interpolation make your commands secure by escaping dangerous characters and wrapping everything in quotes:
    #
    #  Shell.run(["clone ? ?", url, destination], :append_hg => true)
    #
    # ==== :in
    #
    # Allows you to execute commands in a specific directory:
    #
    #  Shell.run('log', :in => repository_path)
    #
    # ==== :pipe
    #
    # Gives you piping flexibility:
    #
    #  Shell.run('log', :pipe => "grep '9:0f41dd2ec166' -wc", :in => repository_path)
    #
    # Same as running +hg log | grep '9:0f41dd2ec166' -wc+
    #
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
    
    #
    # This method is a shortcut to +Shell.run(cmd, :append_hg => true, :in => repository.path)+.
    #
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
