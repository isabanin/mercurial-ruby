module Mercurial
  
  class Node
    
    attr_reader :repository, :name, :hash_id
    
    def initialize(repository, name, options={})
      @repository = repository
      @name = name
      @hash_id = options[:hash_id] || repository.commits.tip.hash_id
      @parent = options[:parent]
    end
    
    def entries
      @_entries ||= repository.nodes.entries_for(self)
    end
    
    def has_entry?(name)
      entries.find do |e|
        e.name == name
      end
    end
    
    def directory?
      not file?
    end
    
    def file?
      (name =~ /\/$/).nil?
    end
    
  end
  
end