module Mercurial
  
  #
  # The class represents Mercurial branch. Obtained by running an +hg branches+ command.
  #
  # The class represents Branch object itself, {Mercurial::BranchFactory BranchFactory} is responsible
  # for assembling instances of Branch. For the list of all possible branch-related operations 
  # check {Mercurial::BranchFactory BranchFactory}.
  #
  # For general information on Mercurial branches:
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
    
    # ID of a commit associated with the branch. 40-chars long SHA1 hash.
    attr_reader :hash_id
    
    def initialize(repository, name, options={})
      @repository    = repository
      @name          = name.strip
      @status        = ['closed', 'inactive'].include?(options[:status]) ? options[:status] : 'active'
      @hash_id       = options[:commit]
    end

    def commit
      repository.commits.by_hash_id(hash_id)
    end
    
    def active?
      status == 'active'
    end

    def inactive?
      status == 'inactive'
    end
    
    def closed?
      status == 'closed'
    end
    
  end
  
end