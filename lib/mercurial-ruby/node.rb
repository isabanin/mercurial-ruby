module Mercurial
  
  class Node
    include Mercurial::Helper
    
    attr_reader :repository, :path, :fmode, :executable, :nodeid, :parent
    
    def initialize(opts={})
      @repository = opts[:repository]
      @path       = opts[:path]
      @parent     = opts[:parent]
      @name       = opts[:name]
      @fmode      = opts[:fmode]
      @executable = opts[:executable] == '*' ? true : false
      @revision   = opts[:revision]
      @nodeid     = opts[:nodeid]
    end
    
    def name
      @name ||= begin
        n = path.split('/').last
        n << '/' if path =~ /\/$/
        n
      end
    end
    
    def revision
      @revision || (parent ? parent.revision : nil) || 'tip'
    end
    
    def path_without_parent
      if parent
        path.gsub(/^#{ Regexp.escape(parent.path) }/, '')
      else
        path
      end
    end
    
    def entries
      @_entries ||= repository.nodes.entries_for(path, revision, self)
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
    
    def root?
      false
    end
    
    def binary?
      false
    end
    
    def contents
      hg(["cat ? -r ?", path, revision])
    end
    
    def size
      contents.size
    end
    
  end
  
end