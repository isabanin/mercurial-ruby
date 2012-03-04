module Mercurial
  
  #
  # This class represents a factory for {Mercurial::Blame Blame} instances.
  #
  class BlameFactory
    include Mercurial::Helper
    
    # Instance of a {Mercurial::Repository Repository}.
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end

    # Finds a blame for a specified file path at a specified revision.
    # Returns an instance of {Mercurial::Blame Blame}.
    #
    # Omit +revision+ if you want the latest blame.
    #
    # === Example:
    #  repository.blames.for_path('some-fancy-directory/all-blame-is-on-me.rb')
    #
    def for_path(path, revision=nil, cmd_options={})
      revision ||= 'tip'
      build do
        hg(["blame ? -ucl -r ?", path, revision], cmd_options)
      end
    end
  
  private
  
    def build(data=nil, &block)
      data ||= block.call
      Mercurial::Blame.new(repository, data)
    end
    
  end
  
end