module Mercurial
  
  VERSION = '0.0.1'
    
end

def require_local(suffix)
  require(File.expand_path(File.join(File.dirname(__FILE__), suffix)))
end

require_local 'mercurial-ruby/shell'
require_local 'mercurial-ruby/helper'
require_local 'mercurial-ruby/repository'
require_local 'mercurial-ruby/config_file'
require_local 'mercurial-ruby/hook'
require_local 'mercurial-ruby/commit'
require_local 'mercurial-ruby/branch'
require_local 'mercurial-ruby/tag'
require_local 'mercurial-ruby/style'

require_local 'mercurial-ruby/factories/hook_factory'
require_local 'mercurial-ruby/factories/commit_factory'
require_local 'mercurial-ruby/factories/branch_factory'
require_local 'mercurial-ruby/factories/tag_factory'
