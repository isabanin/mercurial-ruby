module Mercurial
  
  class Shell
    
    attr_reader :repository
    
    def self.run(cmd, options={})
      options[:cache] ||= true
      build = []

      if options[:in]
        build << "cd #{ options[:in] }"
      end
      
      if cmd.kind_of?(Array)
        cmd = interpolate_arguments(cmd)
      end

      build << cmd
      to_run = build.join(' && ')
      Mercurial::Command.new(to_run, :repository => options[:repository], :cache => options[:cache]).execute
    end
    
    def initialize(repository)
      @repository = repository
    end
    
    def hg(cmd, options={})
      options[:in] ||= repository.path
      options[:repository] = repository
      
      if cmd.kind_of?(Array)
        cmd[0].insert(0, "#{ hg_binary_path } ")
        to_run = cmd
      else
        to_run = "#{ hg_binary_path } #{ cmd }"
      end

      run(to_run, options)
    end
    
    def run(cmd, options={})
      self.class.run(cmd, options)
    end
    
  private
  
    def hg_binary_path
      Mercurial.configuration.hg_binary_path
    end
    
    def self.interpolate_arguments(cmd_with_args)
      cmd_with_args.shift.tap do |cmd|
        cmd.gsub!(/\?/) do
          cmd_with_args.shift.to_s.enclose_in_single_quotes
        end
      end
    end
    
  end
  
end