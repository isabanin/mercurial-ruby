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

    # Return a parent commit for this working copy.
    #
    # === Example:
    #  repository.commits.parent
    #
    def parent(cmd_options={})
      build do
        hg(["parent --style ?", style], cmd_options)
      end
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for all changesets in the repository.
    # Accept a :limit setting.
    #
    # === Example:
    #  repository.commits.all
    #  repository.commits.all(:limit => 15)
    #
    def all(options={}, cmd_options={})
      cmd = command_with_limit(["log --style ?", style], options[:limit])

      hg_to_array(cmd, {:separator => changeset_separator}, cmd_options) do |line|
        build(line)
      end
    end
    
    # Run a block for every {Mercurial::Commit Commit} instance of all changesets in the repository.
    #
    # === Example:
    #  repository.commits.each {|commit| ... }
    #
    def each(cmd_options={}, &block)
      all(cmd_options).each do |commit|
        block.call(commit)
      end
    end
    
    # Count all changesets in the repository.
    #
    # === Example:
    #  repository.commits.count
    #
    def count(cmd_options={})
      hg_to_array(%Q[log --template "{node}\n"], {}, cmd_options) do |line|
        line
      end.size
    end

    # Count changesets in the range from hash_a to hash_b in the repository.
    #
    # === Example:
    #  repository.commits.count_range(hash_a, hash_b)
    #
    def count_range(hash_a, hash_b, cmd_options={})
      hg_to_array([%Q[log -r ?:? --template "{node}\n"], hash_a, hash_b], {}, cmd_options) do |line|
        line
      end.size
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for changesets in a specific branch.
    #
    # === Example:
    #  repository.commits.by_branch('brancname')
    #
    def by_branch(branch, cmd_options={})
      hg_to_array(["log -b ? --style ?", branch, style], {:separator => changeset_separator}, cmd_options) do |line|
        build(line)
      end
    end
    
    # Return an instance of {Mercurial::Commit Commit} for a changeset with a specified id.
    #
    # === Example:
    #  repository.commits.by_hash_id('291a498f04e9')
    #
    def by_hash_id(hash, cmd_options={})
      build do
        hg(["log -r ? --style ?", hash, style], cmd_options)
      end
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for changesets with specified ids.
    #
    # === Example:
    #  repository.commits.by_hash_ids('291a498f04e9', '63f70b2314ed')
    #
    def by_hash_ids(*args)
      cmd_options = args.last.kind_of?(Hash) ? args.last : {}
      
      if args.size == 1 && args.first.kind_of?(Array)
        array = args.first
      else
        array = args
      end      
      return [] if array.empty?

      args = array.map{|hash| " -r#{ hash }"}
      hg_to_array ["log#{ args.join('') } --style ?", style], {:separator => changeset_separator}, cmd_options do |line|
        build(line)
      end
    end
    
    # Return an array of {Mercurial::Commit Commit} instances for a specified range of changeset ids.
    #
    # === Example:
    #  repository.commits.for_range('bf6386c0a0cc', '63f70b2314ed')
    #
    def for_range(hash_a, hash_b, options={}, cmd_options={})
      cmd = command_with_limit(["log -r ?:? --style ?", hash_a, hash_b, style], options[:limit])
      hg_to_array(cmd, {:separator => changeset_separator}, cmd_options) do |line|
        build(line)
      end
    end

    # Return an array of {Mercurial::Commit Commit} instances that appear in hg log before the specified revision id.
    #
    # === Example:
    #  repository.commits.before('bf6386c0a0cc')
    #
    def before(hash_id, options={}, cmd_options={})
      in_direction(:before, hash_id, options, cmd_options)
    end

    # Return an array of {Mercurial::Commit Commit} instances that appear in hg log after the specified revision id.
    #
    # === Example:
    #  repository.commits.after('bf6386c0a0cc')
    #
    def after(hash_id, options={}, cmd_options={})
      in_direction(:after, hash_id, options, cmd_options)
    end
    
    # Return an instance of {Mercurial::Commit Commit} for a repository's tip changeset (latest).
    #
    # === Example:
    #  repository.commits.tip
    #
    def tip(cmd_options={})
      build do
        hg(["tip --style ?", style], cmd_options)
      end
    end
    alias :latest :tip

    # Return an array of {Mercurial::Commit Commit} instances that appear in hg log as ancestors of the specified commit ID.
    #
    # === Example:
    #  repository.commits.ancestors_of('bf6386c0a0cc')
    #
    def ancestors_of(hash_id, options={}, cmd_options={})
      cmd = command_with_limit(["log -r \"ancestors(?)\" --style ?", hash_id, style], options[:limit])
      hg_to_array(cmd, {:separator => changeset_separator}, cmd_options) do |line|
        build(line)
      end
    end
    
  protected

    def in_direction(direction, hash_id, options={}, cmd_options={})
      query = direction.to_sym == :before ? '"reverse(:?)"' : '?:'
      cmd = command_with_limit(["log -r #{ query } --style ?", hash_id, style], options[:limit])

      hg_to_array(cmd, {:separator => changeset_separator}, cmd_options) do |line|
        c = build(line)
        c.short_hash_id == hash_id[0,12] ? next : c
      end
    end
  
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
        :branch_name     => data[9],
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

    def command_with_limit(cmd, limit)
      if limit
        cmd[0] << ' --limit ?'
        cmd << limit
      end
      cmd
    end
    
  end
  
end
