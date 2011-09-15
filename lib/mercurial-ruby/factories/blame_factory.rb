module Mercurial
  
  class BlameFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def for_path(path)
      build do
        hg(["blame ? -uc", path])
      end
    end
  
  private
  
    def build(data=nil, &block)
      data ||= block.call
      Mercurial::Blame.new(repository, data)
    end
    
  end
  
end