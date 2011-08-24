module Mercurial
  
  class NodeFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
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
    entries = hg_to_array("manifest -r #{ revision } --debug") do |line|
      if path == '/' || line.scan(/^\w{40} \d{3} *? (#{ path })/).first != nil
        build(line, parent)
      end
    end
    
    entries = entries.inject({}) do |hash,item|
      hash[item.name] ||= item
      hash 
    end.values
    
    entries
  end
    
  private

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
  end
  
end