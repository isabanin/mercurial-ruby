module Mercurial
  
  #
  # The class represents Mercurial blame output. Obtained by running an +hg blame+ command.
  #
  # This is for the Blame object itself, {Mercurial::BlameFactory BlameFactory} is responsible
  # for assembling instances of the Blame. For the list of all possible blame-related operations please 
  # look documentation for {Mercurial::BlameFactory BlameFactory}.
  #
  class Blame
    
    attr_reader :repository
    attr_reader :contents
    
    def initialize(repository, data)
      @repository = repository
      @contents = data
    end

    #
    # Returns an array of {Mercurial::BlameLine BlameLine} instances.
    #
    def lines
      [].tap do |result|
        contents.each do |line|
          author, revision, linenum, text = line.scan(/^(.+) (\w{12}): *(\d+): (.*)$/).first
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