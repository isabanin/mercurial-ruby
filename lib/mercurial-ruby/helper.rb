module Mercurial
  
  module Helper
    
    def hg(cmd, options={})
      repository.shell.hg(cmd, options)
    end
    
    def shell(cmd, options={})
      repository.shell.run(cmd, options)
    end
    
    def hg_to_array(cmd, options={}, cmd_options={}, &block)
      separator = options[:separator] || "\n"
      [].tap do |returning|
        hg(cmd, cmd_options).split(separator).each do |line|
          returning << block.call(line)
        end
      end.compact
    end
    
  end
  
end