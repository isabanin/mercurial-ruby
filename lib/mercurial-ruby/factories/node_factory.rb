module Mercurial
  
  class NodeFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end    
    
    def find(name, hash_id)
      Mercurial::Node.new(repository, name, hash_id)      
    end
    
    def entries_for_node(node)
      hg_to_array "locate -r #{ hash_id } --include '#{ name }'" do |line|
        build(line)
      end
    end
    
  private
  
    def build(data)
      
    end
    
  end
  
end