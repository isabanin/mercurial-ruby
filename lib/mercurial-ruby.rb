require 'time'

#
# Wrapper module. Nothing interesting here except that you can 
# specify global configs with the +configure+ method.
#
module Mercurial
  
  VERSION = '0.7.12'
  
  class Error < RuntimeError; end
  
  class << self
    attr_accessor :configuration
    
    # Access instance of Mercurial::Configuration.
    #
    #  config = Mercurial.configuration
    #  config.hg_binary_path # => "/usr/local/bin/hg"
    #
    def configuration
      @_configuration ||= Mercurial::Configuration.new
    end
    
    # Change gem's global settings.
    #
    #  Mercurial.configure do |conf|
    #    conf.hg_binary_path = "/usr/bin/hg"
    #  end
    #
    def configure      
      yield(configuration)
    end
  end

end

def require_local(suffix)
  require(File.expand_path(File.join(File.dirname(__FILE__), suffix)))
end

require_local 'stdlib_exts/string'

require_local 'mercurial-ruby/configuration'
require_local 'mercurial-ruby/shell'
require_local 'mercurial-ruby/command'
require_local 'mercurial-ruby/helper'
require_local 'mercurial-ruby/style'
require_local 'mercurial-ruby/repository'
require_local 'mercurial-ruby/config_file'
require_local 'mercurial-ruby/hook'
require_local 'mercurial-ruby/commit'
require_local 'mercurial-ruby/changed_file'
require_local 'mercurial-ruby/diff'
require_local 'mercurial-ruby/branch'
require_local 'mercurial-ruby/tag'
require_local 'mercurial-ruby/manifest'
require_local 'mercurial-ruby/node'
require_local 'mercurial-ruby/root_node'
require_local 'mercurial-ruby/blame'
require_local 'mercurial-ruby/blame_line'
require_local 'mercurial-ruby/file_index'

require_local 'mercurial-ruby/factories/hook_factory'
require_local 'mercurial-ruby/factories/commit_factory'
require_local 'mercurial-ruby/factories/changed_file_factory'
require_local 'mercurial-ruby/factories/diff_factory'
require_local 'mercurial-ruby/factories/branch_factory'
require_local 'mercurial-ruby/factories/tag_factory'
require_local 'mercurial-ruby/factories/node_factory'
require_local 'mercurial-ruby/factories/blame_factory'
