module Mercurial
  
  #
  # The class represents Mercurial blame output. Obtained by running an +hg blame+ command.
  #
  # This is for the Blame object itself, {Mercurial::BlameFactory BlameFactory} is responsible
  # for assembling instances of the Blame. For the list of all possible blame-related operations please 
  # look documentation for {Mercurial::BlameFactory BlameFactory}.
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
        contents.each do |line|
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