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
    
    def add_setting(header, name, value)
      new_setting = %Q{[#{ header }]\n#{ name } = #{ value }\n}
      write do
        if contents.nil?
          new_setting
        elsif contents.scan(header_regexp(header)).empty?
          contents << "\n\n#{ new_setting }"
        else
          contents.gsub(header_regexp(header), new_setting)
        end
      end
    end
    
    def delete_setting!(header, name)
      write do 
        contents.gsub(find_setting(header, name), '')
      end
    end
    
    def find_header(header)
      {}.tap do |returning|
        contents.scan(header_with_content_regexp(header)).flatten.first.split("\n").each do |setting|
          name, value = *setting.split('=').map(&:strip)
          returning[name] = value
        end
      end
    end
    
    def find_setting(header, setting)
      contents.scan(setting_regexp(header, setting)).flatten.first
    end
    
  private
  
    def write(&block)
      new_content = block.call
      File.open(path, 'w') do |f|
        f << new_content
      end
    end
  
    def header_regexp(header)
      /(\[#{ header }\]\s*)/
    end
    
    def header_with_content_regexp(header)
      /\[#{ header }\]\s*([^\[\]]*)/i
    end
    
    def setting_regexp(header, setting)
      /\[#{ header }\]\s*[^\[\]]*(^#{ setting }.+\n*)/i
    end
    
  end
  
end