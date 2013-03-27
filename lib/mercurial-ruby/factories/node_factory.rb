module Mercurial
  class NodeMissing < Error; end

  #
  # This class represents a factory for {Mercurial::Node Node} instances.
  #
  class NodeFactory
    
    # Instance of a {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    # Finds a specified file or a directory in the repository at a specified revision.
    # Returns an instance of {Mercurial::Node Node}.
    #
    # Will find node in the latest version of repo if revision is ommitted.
    # Will return nil if node wasn't found.
    #
    # === Example:
    #  repository.nodes.find('/')
    #  repository.nodes.find('some-fancy-directory/Weird File Name.pdf', '291a498f04e9')
    #  repository.nodes.find('some-fancy-directory/subdirectory/', '291a498f04e9')
    #
    def find(path, revision=nil)
      revision ||= 'tip'
      return RootNode.new(:repository => repository, :revision => revision) if path == '/'
      entry = repository.manifest.scan_for_path(path, revision).first
      return unless entry
      if exact_path = entry[3].scan(/^(#{ Regexp.escape(path.without_trailing_slash) }\/)/).flatten.first
        name = exact_path.split('/').last + '/'
        build(
          :path     => exact_path,
          :name     => name,
          :revision => revision
        )
      else
        build(
          :path     => entry[3],
          :name     => entry[3].split('/').last,
          :revision => revision,
          :nodeid   => entry[0],
          :fmode    => entry[1],
          :exec     => entry[2]
        )
      end
    end
    
    # Same as +find+ but will raise a NodeMissing exception if node wasn't found.
    def find!(path, revision=nil)
      find(path, revision) || raise(NodeMissing, "#{ path } at revision #{ revision }")
    end
    
    # Find all entries (files and directories) inside a specified path and revision.
    # Returns an array of {Mercurial::Node Node} instances.
    #
    # Will find node in the latest version of repo if revision is ommitted.
    #
    # === Example:
    #  repository.nodes.entries_for('/')
    #  repository.nodes.entries_for('some-fancy-directory/subdirectory/', '291a498f04e9')
    #
    def entries_for(path, revision=nil, parent=nil)
      revision ||= 'tip'
      [].tap do |entries|
        manifest_entries = repository.manifest.scan_for_path(path, revision)
        manifest_entries.each do |me|
          path_without_source = me[3].gsub(/^#{ Regexp.escape(path.without_trailing_slash) }\//, '')
          entry_name = path_without_source.split('/').first
          entry_path = File.join(path, entry_name).gsub(/^\//, '')
          dir = me[3].scan(/^(#{ Regexp.escape(entry_path) }\/)/).flatten.first ? true : false
          entry_name << '/' if dir
          
          if entries.select{|item| item.name == entry_name}.size == 0
            entries << build(
              :path     => entry_path,
              :name     => entry_name,
              :revision => revision,
              :nodeid   => (me[0] unless dir),
              :fmode    => dir ? nil : me[1],
              :exec     => dir ? nil : me[2],
              :parent   => parent
            )
          end
        end
      end
    end
    
  private
  
    def build(opts={})
      Mercurial::Node.new(
        :repository => repository,
        :path       => opts[:path],
        :name       => opts[:name],
        :revision   => opts[:revision],
        :nodeid     => opts[:nodeid],
        :fmode      => opts[:fmode],
        :executable => opts[:exec],
        :parent     => opts[:parent]
      )
    end
    
  end
  
end