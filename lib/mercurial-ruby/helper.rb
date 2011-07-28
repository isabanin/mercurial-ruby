module Mercurial
  
  module Helper
    
    def hg(cmd)
      Mercurial::Shell.hg(cmd, :in => repository.path)
    end
    
    def shell(cmd)
      Mercurial::Shell.run(cmd)
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