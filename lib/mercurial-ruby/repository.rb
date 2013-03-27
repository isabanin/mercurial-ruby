module Mercurial  
  class RepositoryNotFound < Error; end
  
  #
  # This class represents a Mercurial repository. Most of the time you will use this as a proxy for
  # all your hg operations.
  #
  class Repository
    
    #
    # Creates a new repository on disk. Returns a {Mercurial::Repository Repository} instance.
    #
    # === Example:
    #  Mercurial::Repository.create("/Users/ilya/Desktop/cool_repository")
    #
    def self.create(destination)
      init_repository(destination)      
    end
    
    #
    # Opens an existing repository on disk. Returns a {Mercurial::Repository Repository} instance.
    #
    # === Example:
    #  Mercurial::Repository.open("/Users/ilya/Desktop/existing-repo")
    #
    def self.open(destination)
      if File.exists?(destination)
        new(destination)
      else
        raise Mercurial::RepositoryNotFound.new(destination)
      end
    end

    #
    # Creates a clone of an existing repository via URL.
    #
    # === Example:
    #  Mercurial::Repository.clone("file:///Users/ilya/Desktop/existing-repo", "/path/to/the/clone")
    #
    def self.clone(url, destination, cmd_options)
      create_destination(destination)
      opts = cmd_options.merge(:append_hg => true)
      Mercurial::Shell.run(["clone ? ?", url, destination], opts)
      open(destination)      
    end
    
    def initialize(source)
      @path = source
    end
    
    #
    # Returns an instance of {Mercurial::Shell Shell} attached to the repository.
    #
    def shell
      @_shell ||= Mercurial::Shell.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::ConfigFile ConfigFile} attached to the repository.
    #
    def config
      @_config ||= Mercurial::ConfigFile.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::HookFactory HookFactory} attached to the repository.
    #
    def hooks
      @_hook_factory ||= Mercurial::HookFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::CommitFactory CommitFactory} attached to the repository.
    #
    def commits
      @_commits ||= Mercurial::CommitFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::BranchFactory BranchFactory} attached to the repository.
    #
    def branches
      @_branches ||= Mercurial::BranchFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::TagFactory TagFactory} attached to the repository.
    #
    def tags
      @_tags ||= Mercurial::TagFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::DiffFactory DiffFactory} attached to the repository.
    #
    def diffs
      @_diffs ||= Mercurial::DiffFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::NodeFactory NodeFactory} attached to the repository.
    #
    def nodes
      @_nodes ||= Mercurial::NodeFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::BlameFactory BlameFactory} attached to the repository.
    #
    def blames
      @_blames ||= Mercurial::BlameFactory.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::Manifest Manifest} attached to the repository.
    #
    def manifest
      @_manifest ||= Mercurial::Manifest.new(self)
    end
    
    #
    # Returns an instance of {Mercurial::FileIndex FileIndex} attached to the repository.
    #
    def file_index
      @_file_index ||= Mercurial::FileIndex.new(self)
    end
    
    #
    # Shortcut for +nodes.find+.
    #
    def node(name, hash_id)
      nodes.find(name, hash_id)
    end
    
    def clone(destination_path, cmd_options={})
      self.class.clone(file_system_url, destination_path, cmd_options)
    end
    
    #
    # Pull from an origin.
    #
    # === Example:
    #  repository.pull
    #
    def pull(origin='default', cmd_options={})
      shell.hg(['pull ?', origin], cmd_options)
    end
    
    #
    # Run +hg verify+ on the repository. Returns +true+ if verified, +false+ otherwise.
    #
    def verify
      shell.hg('verify')
      true
    rescue Mercurial::CommandError
      false
    end

    #
    # Returns an array of repository's paths (as remotes).
    #
    def paths
      {}.tap do |result|
        shell.hg('paths').each_line do |line|
          path, url = *line.strip.split(" = ")
          result[path] = url
        end
      end
    end
    
    #
    # Deletes the repository from disk.
    #
    def destroy!
      FileUtils.rm_rf(path)
    end
    
    def file_system_url
      %Q[file://#{ path }]
    end
    
    def path
      File.expand_path(@path)
    end
    
    def dothg_path
      File.join(path, '.hg')
    end
    
    def mtime
      File.mtime(dothg_path).to_i
    end
    
    #
    # Accepts a block, executes all commands inside the block with caching disabled.
    #
    # === Example:
    #
    #  repository.no_cache do
    #    repository.commits.all
    #    repository.branches.all
    #  end
    #
    # Same as:
    #
    #  repository.commits.all :cache => false
    #  repository.branches.all :cache => false
    #
    def no_cache
      @cache_disabled_by_override = true
      yield
    ensure
      @cache_disabled_by_override = false
    end
    
    def cache_disabled_by_override?
      @cache_disabled_by_override || false
    end
    
  protected

    def self.create_destination(path)
      Mercurial::Shell.run("mkdir -p #{ path }")
    end
  
    def self.init_repository(destination)
      create_destination(destination)
      open(destination).tap do |repo|
        repo.shell.hg('init', :cache => false)
        repo.shell.hg('update null', :cache => false)
      end
    end
    
  end
  
end
