module Mercurial
  
  #
  # This class represents a factory for {Mercurial::Branch Branch} instances.
  #
  class BranchFactory
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    # Return an array of {Mercurial::Branch Branch} instances for all branches in the repository.
    #
    # === Example:
    #  repository.branches.all 
    #
    def all(cmd_options={})
      hg_to_array("branches -c --debug", {}, cmd_options) do |line|
        build(line)
      end
    end

    # Run a block for every {Mercurial::Branch Branch} instance of all branches in the repository.
    #
    # === Example:
    #  repository.branches.each {|commit| ... }
    #
    def each(cmd_options={}, &block)
      all(cmd_options).each do |branch|
        block.call(branch)
      end
    end
    
    # Return an array of {Mercurial::Branch Branch} instances for all active branches in the repository.
    #
    # === Example:
    #  repository.branches.active
    #
    def active(cmd_options={})
      all(cmd_options).find_all do |b|
        b.active?
      end
    end

    # Return an array of {Mercurial::Branch Branch} instances for all inactive branches in the repository.
    #
    # === Example:
    #  repository.branches.inactive
    #
    def inactive(cmd_options={})
      all(cmd_options).find_all do |b|
        b.inactive?
      end
    end

    # Return an array of {Mercurial::Branch Branch} instances for all closed branches in the repository.
    #
    # === Example:
    #  repository.branches.closed
    #
    def closed(cmd_options={})
      all(cmd_options).find_all do |b|
        b.closed?
      end
    end
    
    # Return a {Mercurial::Branch Branch} instance for a branch with a specified name.
    #
    # === Example:
    #  repository.branches.by_name('branchname')
    #
    def by_name(name, cmd_options={})
      all(cmd_options).find do |b|
        b.name == name
      end
    end
    
    # Return an array of {Mercurial::Branch Branch} instances where a specified commit exists.
    # Experimental, doesn't always return a correct list of branches.
    #
    # === Example:
    #  repository.branches.for_commit('291a498f04e9')
    #
    def for_commit(hash_id, cmd_options={})
      hg_to_array(["log -r 'descendants(?) and head()' --template '\n{branches}'", hash_id], {}, cmd_options) do |line|
        build_with_name_only(line)
      end.compact.uniq
    end
    
  private
  
    def build(data)
      name, last_commit, status = *data.scan(/([\w\- ]+)\s+\d+:(\w+)\s*\(*(\w*)\)*/).first
      Mercurial::Branch.new(
        repository,
        name,
        :commit => last_commit,
        :status => status
      )
    end
    
    def build_with_name_only(name)
      name = 'default' if name == ''
      Mercurial::Branch.new(repository, name)
    end

  end
  
end