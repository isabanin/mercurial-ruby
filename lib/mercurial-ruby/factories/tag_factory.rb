module Mercurial

  #
  # This class represents a factory for {Mercurial::Tag Tag} instances.
  #
  class TagFactory
    include Mercurial::Helper
    
    # Instance of {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    # Return an array of {Mercurial::Tag Tag} instances for all tags in the repository.
    #
    # === Example:
    #  repository.tags.all 
    #
    def all(cmd_options={})
      hg_to_array("tags", {}, cmd_options) do |line|
        build(line)
      end
    end
    
    # Return a {Mercurial::Tag Tag} instance for a tag with a specified name.
    #
    # === Example:
    #  repository.tags.by_name('tagname')
    #
    def by_name(name, cmd_options={})
      all(cmd_options).find do |b|
        b.name == name
      end
    end
    
  private
  
    def build(data)
      name, hash_id = *data.scan(/([\w-]+)\s+\d+:(\w+)\s*/).first
      return if name == 'tip'
      Mercurial::Tag.new(repository, name, hash_id)
    end

  end
  
end