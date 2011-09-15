module Mercurial
  
  class BlameLine
    
    attr_reader :author
    attr_reader :num
    attr_reader :revision
    attr_reader :contents
    
    def initialize(attrs={})
      @author   = attrs[:author]
      @num      = attrs[:num].to_i
      @revision = attrs[:revision]
      @contents = attrs[:contents]
    end
    
  end
  
end