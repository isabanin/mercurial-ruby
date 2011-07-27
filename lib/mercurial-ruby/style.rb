module Mercurial
  
  module Style
    extend self
    
    TEMPLATE_SEPARATOR = '|><|'
    
    def root_path
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'styles'))
    end
    
    def changeset
      File.join(root_path, 'changeset.style')
    end
    
  end
  
end