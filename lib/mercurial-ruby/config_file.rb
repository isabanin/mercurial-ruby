module Mercurial
  
  class ConfigFile
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def path
      File.join(repository.path, '.hg', 'hgrc')
    end
    
    def exists?
      File.exists?(path)
    end
    
    def contents
      File.read(path) if exists?
    end
    
    def write(&block)
      new_content = block.call
      File.open(path, 'w') do |f|
        f << new_content
      end
    end
    
    def add_setting(header, name, value)
      write do
        contents.gsub(/(\[#{ header }\]\s*)/, %Q{[#{ header }]\n#{ name } = #{ value }\n})
      end
    end
    
    def delete_setting!(header, name)
      write do 
        contents.gsub(find_setting(header, name), '')
      end
    end
    
    def find_header(header)
      {}.tap do |returning|
        contents.scan(/\[#{ header }\]\s*([^\[\]]*)/i).flatten.first.split("\n").each do |setting|
          name, value = *setting.split('=').map(&:strip)
          returning[name] = value
        end
      end
    end
    
    def find_setting(header, setting)
      contents.scan(/\[#{ header }\]\s*[^\[\]]*(^#{ setting }.+\n*)/i).flatten.first
    end
    
  end
  
end