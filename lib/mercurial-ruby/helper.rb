module Mercurial
  
  module Helper
    
    def hg(cmd, options={})
      repository.shell.hg(cmd)
    end
    
    def shell(cmd, options={})
      repository.shell.run(cmd)
    end
    
    def hg_to_array(cmd, separator="\n", &block)
      [].tap do |returning|
        hg(cmd).split(separator).each do |line|
          returning << block.call(line)
        end
      end.compact
    end
    
  end
  
end