module Mercurial
  
  module Style
    extend self
    
    FIELD_SEPARATOR = '|><|'
    CHANGESET_SEPARATOR = "||$||\n"
    
    def root_path
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'styles'))
    end
    
    def changeset
      File.join(root_path, 'changeset.style')
    end
    
    def file_index
      File.join(root_path, 'file_index.style')
    end
    
  end
  
end