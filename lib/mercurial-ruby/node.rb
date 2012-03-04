module Mercurial
  
  #
  # This class represents a file or a directory stored inside a repository. The data is provided by {Mercurial::Manifest Manifest}.
  #
  # To see how Node instances are assembled, check the {Mercurial::NodeFactory NodeFactory}.
  #
  class Node
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    # Absolute path to the node.
    attr_reader :path
    
    # File mode of the node in Octal notation (if file).
    attr_reader :fmode
    
    # Executable flag of the node (if file).
    attr_reader :executable
    
    # nodeid value for the node (if file).
    attr_reader :nodeid
    
    # Node's parent, instance of {Mercurial::Node Node}.
    attr_reader :parent
    
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
    
    def diff_to(revision_b, options={})
      repository.diffs.for_path(path, revision, revision_b, options)
    end
    
    def blame
      repository.blames.for_path(path, revision)
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
