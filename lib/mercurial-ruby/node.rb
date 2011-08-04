module Mercurial
  
  class Node
    include Mercurial::Helper
    
    attr_reader :repository, :path, :commit_id, :parent
    
    def initialize(opts={})
      @repository = opts[:repository]
      @path       = opts[:path]
      @parent     = opts[:parent]
      @name       = opts[:name]
      @commit_id  = opts[:commit_id] || repository.commits.tip.hash_id      
    end
    
    def name
      @name ||= begin
        n = path.split('/').last
        n << '/' if path =~ /\/$/
        n
      end
    end
    
    def path_without_parent
      if parent
        path.gsub(/^#{ parent.path }/, '')
      else
        path
      end
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
    
    def binary?
      false
    end
    
    def contents
      hg("cat #{ path } -r #{ commit_id }")
    end
    
  end
  
end