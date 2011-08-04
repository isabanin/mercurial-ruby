module Mercurial
  
  class NodeFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end    
    
    def find(path, hash_id=nil)
      Mercurial::Node.new(
        :repository => repository,
        :path       => path,
        :commit_id  => hash_id
      )
    end
    
    def entries_for(node)
      entries = hg_to_array "locate -r #{ node.commit_id } --include '#{ node.name }'" do |line|
        build(line, node)
      end
      
      entries = entries.inject({}) do |hash,item|
        hash[item.name] ||= item
        hash 
      end.values
      
      entries
    end
    
  private
  
    def build(data, parent)
      path_array = data.strip.gsub(/^#{ parent.path }/, '').split('/')
      path = "#{parent.path}#{path_array.first}"
      name = path_array.first
      name << '/' if path_array.size > 1
      Mercurial::Node.new(
        :repository => repository,
        :path       => path,
        :name       => name,
        :parent     => parent,
        :commit_id  => parent.commit_id
      )
    end
    
  end
  
end