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
      path = path.without_trailing_slash
      if path == '/' || path == ''
        search_for = ".*"
      else
        path_re = Regexp.escape(path)
        search_for = "#{ path_re }$|#{ path_re }\/.*"
      end
      contents(revision).scan(/^(\w{40}) (\d{3}) (\*?) +(#{ search_for })/)
    end
    
  private
  
    def manifest_cmd(revision)
      ["manifest -r ? --debug", revision]
    end
  end
    
end