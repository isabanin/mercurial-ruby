module Mercurial
  
  #
  # Represents Mercurial manifest file. Use this class to get manifest's contents
  # and scan it for file paths at specific revisions.
  #
  # Read more about Mercurial manifest:
  #
  # http://mercurial.selenic.com/wiki/Manifest
  #
  class Manifest
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    # Returns contents of the manifest as a String at a specified revision.
    # Latest version of the manifest is used if +revision+ is ommitted.
    #
    # === Example:
    #  repository.manifest.contents
    #
    def contents(revision=nil, cmd_options={})
      revision ||= 'tip'
      hg(manifest_cmd(revision), cmd_options).tap do |res|
        if RUBY_VERSION >= '1.9.1'
          res.force_encoding('utf-8')
        end
      end
    end
    
    # Returns an array of file paths from manifest that start with the specified +path+ at a specified +revision+.
    # Latest version of the manifest is used if +revision+ is ommitted.
    #
    # === Example:
    #  repository.manifest.scan_for_path('/')
    #  repository.manifest.scan_for_path('some-interesting-directory/', '2d32410d9629')
    #
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
