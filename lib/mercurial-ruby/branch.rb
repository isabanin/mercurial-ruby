module Mercurial
  
  #
  # The class represents Mercurial branch. Obtained by running an +hg branches+ command.
  #
  # The class represents Branch object itself, {Mercurial::BranchFactory BranchFactory} is responsible
  # for assembling instances of Branch. For the list of all possible branch-related operations please 
  # look documentation for {Mercurial::BranchFactory BranchFactory}.
  #
  # Read more about Mercurial branches:
  #
  # http://mercurial.selenic.com/wiki/Branch
  #
  class Branch
   
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    # Name of the branch.
    attr_reader :name
    
    # State of the branch: closed or active.
    attr_reader :status
    
    # Mercurial changeset ID of the latest commit in the branch. 40-chars long SHA1 hash.
    attr_reader :latest_commit
    
    def initialize(repository, name, options={})
      @repository    = repository
      @name          = name
      @status        = options[:status] == 'closed' ? 'closed' : 'active'
      @latest_commit = options[:commit]
    end
    
    def active?
      status == 'active'
    end
    
    def closed?
      status == 'closed'
    end
    
  end
  
end