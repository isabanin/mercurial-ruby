module Mercurial
  
  module Helper
    
    def hg(cmd)
      repository.shell.hg(cmd)
    end
    
    def shell(cmd)
      repository.shell.run(cmd)
    end
    
    def hg_to_array(cmd, &block)
      [].tap do |returning|
        hg(cmd).split("\n").each do |line|
          returning << block.call(line)
        end
      end.compact
    end
    
  end
  
end