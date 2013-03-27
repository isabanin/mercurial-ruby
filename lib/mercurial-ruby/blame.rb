module Mercurial
  
  #
  # The class represents Mercurial blame output (+hg blame+ command).
  #
  # This class is for Blame object itself, {Mercurial::BlameFactory BlameFactory} is responsible
  # for assembling instances of Blame. For the list of all possible blame-related operations 
  # check {Mercurial::BlameFactory BlameFactory}.
  #
  class Blame

    METADATA_RE = /^(.+) (\w{12}): *(\d+): /
    METADATA_AND_CODE_RE = /^(.+) (\w{12}): *(\d+): (.*)$/
    
    attr_reader :repository
    attr_reader :contents
    
    def initialize(repository, data)
      @repository = repository
      @contents = data
    end

    #
    # Returns code only as a String without the usual blame metadata.
    # Useful for code highlighting.
    #
    def contents_without_metadata
      contents.gsub(METADATA_RE, '')
    end

    #
    # Returns an Array of blame metadata for every line of blame.
    # Does not return code itself.
    #
    def raw_metadata
      contents.scan(METADATA_RE)
    end

    #
    # Returns an array of {Mercurial::BlameLine BlameLine} instances.
    #
    def lines
      [].tap do |result|
        contents.each_line do |line|
          author, revision, linenum, text = line.scan(METADATA_AND_CODE_RE).first
          result << BlameLine.new(
            :author   => author,
            :revision => revision,
            :num      => linenum,
            :contents => text
          )
        end
      end
    end
    
  end
  
end