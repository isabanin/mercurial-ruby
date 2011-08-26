module Mercurial
  
  class Error < RuntimeError; end
  
  class RepositoryNotFound < Error; end
  
  class CommandError < Error; end
  
end