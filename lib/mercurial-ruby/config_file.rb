module Mercurial

  #
  # Represents +.hg/hgrc+ configuration from the repository.
  # Useful for adding/removing various settings.
  #
  # For general information on hgrc:
  #
  # http://www.selenic.com/mercurial/hgrc.5.html
  #
  class ConfigFile

    class DuplicateSetting < Error; end
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    #
    # Returns an absolute path to the config file:
    #
    #  config.path # => /home/ilya/repos/fancyrepo/.hg/hgrc
    #
    def path
      File.join(repository.path, '.hg', 'hgrc')
    end
    
    #
    # Returns true if the config file actually exists on disk.
    # The file is usually missing in new repositories.
    #
    def exists?
      File.exists?(path)
    end
    
    #
    # Returns contents of the config file as a string.
    #
    def contents
      File.read(path) if exists?
    end
    
    #
    # Adds specified setting to a specified section of the config:
    #
    #  config.add_setting('merge-tools', 'kdiff3.executable', '~/bin/kdiff3')
    # 
    # will write the following content to hgrc:
    #
    #  [merge-tools]
    #  kdiff3.executable = ~/bin/kdiff3
    #
    def add_setting(header, name, value)
      raise DuplicateSetting if setting_exists?(header, name)

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
    
    #
    # Removes specified setting from hgrc:
    #
    #  config.delete_setting!('merge-tools', 'kdiff3.executable')
    #
    def delete_setting!(header, name)
      write do 
        contents.gsub(find_setting(header, name), '')
      end
    end

    #
    # Returns true if a specified setting exists in specified group.
    #
    #  config.setting_exists?('hooks', 'changegroup')
    #
    def setting_exists?(header, name)
      !!find_setting(header, name)
    end
    
    #
    # Returns content of the specified section of hgrc.
    #
    def find_header(header)
      {}.tap do |returning|
        contents.scan(header_with_content_regexp(header)).flatten.first.split("\n").each do |setting|
          name, value = *setting.split('=').map(&:strip)
          returning[name] = value
        end
      end
    end
    
    #
    # Returns content of the specified setting from a section.
    #
    def find_setting(header, setting) #:nodoc:
      return nil if contents.nil?
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
      /(\[#{ Regexp.escape(header) }\]\s*)/
    end
    
    def header_with_content_regexp(header)
      /\[#{ Regexp.escape(header) }\]\s*([^\[\]]*)/i
    end
    
    def setting_regexp(header, setting)
      /\[#{ Regexp.escape(header) }\]\s*[^\[\]]*(^#{ Regexp.escape(setting) }.+\n*)/i
    end
    
  end
  
end
