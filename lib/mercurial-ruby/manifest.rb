module Mercurial
  
  class Manifest
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def contents(revision=nil)
      revision ||= 'tip'
      hg(manifest_cmd(revision))
    end
    
    def scan_for_path(path, revision=nil)
      revision ||= 'tip'
      path = path.gsub(/\/$/, '')
      if path == '/' || path == ''
        search_for = ".*"
      else
        search_for = "#{ path }$|#{ path }\/.*"
      end
      hg(manifest_cmd(revision)).scan(/^(\w{40}) (\d{3}) (\*?) +(#{ search_for })/)
    end
    
  private
  
    def manifest_cmd(revision)
      "manifest -r #{ revision } --debug"
    end
  end
    
end