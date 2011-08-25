module Mercurial
  
  class NodeFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end    
    
    def find(path, revision=nil)
      revision ||= 'tip'

      return RootNode.new(:repository => repository) if path == '/'

      entry = repository.manifest.scan_for_path(path, revision).first
      if exact_path = entry[3].scan(/^(#{ path.gsub(/\/$/, '') }\/)/).flatten.first
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
          :fmode    => entry[1],
          :exec     => entry[2]
        )
      end
    end
    
    def entries_for(path, revision=nil, parent=nil)
      revision ||= 'tip'
      entries = []
      manifest_entries = repository.manifest.scan_for_path(path, revision)
      manifest_entries.each do |me|
        path_without_source = me[3].gsub(/^#{ path.gsub(/\/$/, '') }\//, '')
        entry_name = path_without_source.split('/').first
        entry_path = File.join(path, entry_name)
        dir = me[3].scan(/^(#{ entry_path }\/)/).flatten.first ? true : false
        entry_name << '/' if dir
        
        entries << build(
          :path     => entry_path,
          :name     => entry_name,
          :revision => dir ? revision : me[0],
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
        :fmode      => opts[:fmode],
        :executable => opts[:exec],
        :parent     => opts[:parent]
      )
    end

=begin
    def find(path, revision=nil)
      if manifest_line = repository.manifest.find(path, revision)
        build(
          :revision => revision, #manifest_line[0],
          :fmode    => manifest_line[1],
          :path     => manifest_line[2]
        )
      end
    end
    
    def entries_for(path, revision=nil, parent=nil)
      repository.manifest.each_entry(path, revision) do |entry|
        build(
          :revision => entry[0],
          :fmode    => entry[1],
          :path     => entry[2],
          :parent   => parent
        )
      end
    end

   
    def find(path, revision=nil)
      parent_dir = path.split('/')[-2]

      if parent_dir.nil?
        entries = entries_for('/', revision)
      else
        entries = entries_for(parent_dir, revision)
      end
      
      entries.find do |entry|
        entry.path == path
      end
    end

    def entries_for(path, revision=nil, parent=nil)
      [].tap do |entries|
        repository.manifest.each_file(path, revision) do |line|
          if path == '/' || line.scan(/^\w{40} \d{3} *? (#{ path })/).first != nil
            entries << build(line, parent)
          end
        end
    
        entries = entries.inject({}) do |hash,item|
          hash[item.name] ||= item
          hash 
        end.values
      end
    end

  def build(opts={})
      path_arr = opts[:path].split('/')
      name = path_arr.last
      
      if opts[:path].strip.scan(/\/$/).first
        name << '/'
      end
      
      Mercurial::Node.new(
        :repository => repository,
        :path       => opts[:path],
        :name       => name,
        :parent     => opts[:parent],
        :revision   => opts[:revision],
        :fmode      => opts[:fmode]
      )
    end
    
    def build(data, parent=nil)
      parent_path = parent ? parent.path : ''
      revision, fmode, path = *data.strip.scan(/^(\w{40}) (\d{3}) *? (.+)/).first
      path = path.strip
      path_array = path.gsub(/^#{ parent_path }/, '').split('/')
      path = "#{parent_path}#{path_array.first}"
      name = path_array.first
      name << '/' if path_array.size > 1
      path << '/' if path_array.size > 1

      Mercurial::Node.new(
        :repository => repository,
        :path       => path,
        :name       => name,
        :parent     => parent,
        :revision   => revision,
        :fmode      => fmode
      )
    end
=end
    
  end
  
end