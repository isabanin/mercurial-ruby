module Mercurial
  
  class Blame
    
    attr_reader :repository
    attr_reader :contents
    
    def initialize(repository, data)
      @repository = repository
      @contents = data
    end
    
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