module Mercurial
  class NodeMissing < Error; end
  
  class NodeFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end    
    
    def find(path, revision=nil)
      revision ||= 'tip'
      return RootNode.new(:repository => repository, :revision => revision) if path == '/'
      entry = repository.manifest.scan_for_path(path, revision).first
      return unless entry
      if exact_path = entry[3].scan(/^(#{ Regexp.escape(path.gsub(/\/$/, '')) }\/)/).flatten.first
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
    
    def find!(path, revision=nil)
      find(path, revision) || raise(NodeMissing, "#{ path } at revision #{ revision }")
    end
    
    def entries_for(path, revision=nil, parent=nil)
      revision ||= 'tip'
      entries = []
      manifest_entries = repository.manifest.scan_for_path(path, revision)
      manifest_entries.each do |me|
        path_without_source = me[3].gsub(/^#{ Regexp.escape(path.gsub(/\/$/, '')) }\//, '')
        entry_name = path_without_source.split('/').first
        entry_path = File.join(path, entry_name).gsub(/^\//, '')
        dir = me[3].scan(/^(#{ Regexp.escape(entry_path) }\/)/).flatten.first ? true : false
        entry_name << '/' if dir
        
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
      
      entries = entries.inject({}) do |hash,item|
        hash[item.name] ||= item
        hash 
      end.values
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