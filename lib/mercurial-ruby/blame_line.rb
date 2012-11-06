module Mercurial

  #
  # The class represents a single line of the blame output.
  #  
  class BlameLine
    
    # Commit author.
    attr_reader :author

    # Line number.
    attr_reader :num

    # ID of the commit associated with the line.
    attr_reader :revision

    # Contents of the line.
    attr_reader :contents
    
    def initialize(attrs={})
      @author   = attrs[:author]
      @num      = attrs[:num].to_i
      @revision = attrs[:revision]
      @contents = attrs[:contents]
    end
    
  end
  
end