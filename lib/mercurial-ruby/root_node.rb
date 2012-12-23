module Mercurial
  
  class RootNode < Node
    
    def directory?
      true
    end
    
    def file?
      false
    end
    
    def root?
      true
    end
    
    def binary?
      false
    end

    def name
      ''
    end
    
    def path
      ''
    end
    
  end
  
end