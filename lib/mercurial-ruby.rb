module Mercurial
  
  VERSION = '0.0.1'
    
end

require 'mercurial-ruby/shell'
require 'mercurial-ruby/repository'
require 'mercurial-ruby/config_file'
require 'mercurial-ruby/hook'
require 'mercurial-ruby/commit'
require 'mercurial-ruby/branch'
require 'mercurial-ruby/tag'
require 'mercurial-ruby/style'

require 'mercurial-ruby/factories/hook_factory'
require 'mercurial-ruby/factories/commit_factory'
require 'mercurial-ruby/factories/branch_factory'
require 'mercurial-ruby/factories/tag_factory'
