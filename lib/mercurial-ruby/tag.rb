module Mercurial
  
  #
  # The class represents Mercurial tag. Obtained by running an +hg tags+ command.
  #
  # The class represents Tag object itself, {Mercurial::TagFactory TagFactory} is responsible
  # for assembling instances of Tag. For the list of all possible tag-related operations please 
  # check {Mercurial::TagFactory TagFactory}.
  #
  # For general information on Mercurial tags:
  #
  # http://mercurial.selenic.com/wiki/Tag
  #
  class Tag
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    # Name of the tag.
    attr_reader :name
    
    # Mercurial changeset ID of the tag. 40-chars long SHA1 hash.
    attr_reader :hash_id
    
    def initialize(repository, name, hash_id)
      @repository = repository
      @name       = name
      @hash_id    = hash_id
    end
    
  end
  
end