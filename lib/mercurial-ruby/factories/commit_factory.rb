module Mercurial
  
  #
  # This class represents a factory for {Mercurial::Commit Commit} instances.
  #
  class CommitFactory
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository) #:nodoc:
      @repository = repository
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for all changesets in the repository.
    #
    # == Example:
    #  repository.commits.all 
    #
    def all
      hg_to_array ["log --style ?", style], changeset_separator do |line|
        build(line)
      end
    end
    
    # Run a block for every {Mercurial::Commit Commit} instance of all changesets in the repository.
    #
    # == Example:
    #  repository.commits.each {|commit| ... }
    #
    def each(&block)
      all.each do |commit|
        block.call(commit)
      end
    end
    
    # Count all changesets in the repository.
    #
    # == Example:
    #  repository.commits.count
    #
    def count
      hg_to_array %Q[log --template "{node}\n"], "\n" do |line|
        line
      end.size
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for changesets in a specific branch.
    #
    # == Example:
    #  repository.commits.by_branch('brancname')
    #
    def by_branch(branch)
      hg_to_array ["log -b ? --style ?", branch, style], changeset_separator do |line|
        build(line)
      end
    end
    
    # Return an instance of {Mercurial::Commit Commit} for a changeset with a specified id.
    #
    # == Example:
    #  repository.commits.by_hash_id('291a498f04e9')
    #
    def by_hash_id(hash)
      build do
        hg(["log -r ? --style ?", hash, style])
      end
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for changesets with specified ids.
    #
    # == Example:
    #  repository.commits.by_hash_ids('291a498f04e9', '63f70b2314ed')
    #
    def by_hash_ids(*args)
      if args.size == 1 && args.first.kind_of?(Array)
        array = args.first
      else
        array = args
      end      
      return [] if array.empty?

      args = array.map{|hash| " -r#{ hash }"}
      hg_to_array ["log#{ args } --style ?", style], changeset_separator do |line|
        build(line)
      end
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for a specified range of changeset ids.
    #
    # == Example:
    #  repository.commits.for_range('bf6386c0a0cc', '63f70b2314ed')
    #
    def for_range(hash_a, hash_b)
      hg_to_array ["log -r ?:? --style ?", hash_a, hash_b, style], changeset_separator do |line|
        build(line)
      end
    end
    
    # Return an instance of {Mercurial::Commit Commit} for a repository's tip changeset (latest).
    #
    # == Example:
    #  repository.commits.tip
    #
    def tip
      build do
        hg(["tip --style ?", style])
      end
    end
    alias :latest :tip
    
  protected
  
    def changeset_separator
      Mercurial::Style::CHANGESET_SEPARATOR
    end
    
    def field_separator
      Mercurial::Style::FIELD_SEPARATOR
    end
  
    def build(data=nil, &block)
      data ||= block.call
      return if data.empty?
      data = data.gsub(/#{ Regexp.escape(changeset_separator) }$/, '')
      data = data.split(field_separator)
      commit = Mercurial::Commit.new(
        repository,
        :hash_id         => data[0],
        :author          => data[1],
        :author_email    => data[2],
        :date            => data[3],
        :message         => data[4],
        :changed_files   => [data[5], data[6], data[7], data[8]],
        :branches_names  => data[9],
        :tags_names      => data[10],
        :parents         => data[11]
      )
      
      if commit.blank?
        nil
      else
        commit
      end
    end
  
    def style
      Mercurial::Style.changeset
    end
    
  end
  
end