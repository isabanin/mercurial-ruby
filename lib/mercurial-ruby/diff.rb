module Mercurial

  #
  # The class represents Mercurial diff. Obtained by running an +hg diff+ command.
  #
  # The class represents Diff object itself, {Mercurial::DiffFactory DiffFactory} is responsible
  # for assembling instances of Diff. For the list of all possible diff-related operations 
  # check {Mercurial::DiffFactory DiffFactory}.
  #
  class Diff
    
    # SHA1 hash of version a of the file.
    attr_reader :hash_a
    
    # SHA1 hash of version b of the file.
    attr_reader :hash_b
    
    # Version a of the file name.
    attr_reader :file_a
    
    # Version b of the file name.
    attr_reader :file_b
    
    # Diff body.
    attr_reader :body
    
    def initialize(opts={})
      @hash_a = opts[:hash_a]
      @hash_b = opts[:hash_b]
      @file_a = opts[:file_a]
      @file_b = opts[:file_b]
      @body   = opts[:body]
      @binary = opts[:binary]

      if RUBY_VERSION >= '1.9.1'
        @file_a.force_encoding('utf-8') if @file_a
        @file_b.force_encoding('utf-8') if @file_b
      end
    end
    
    def file_name
      file_b || file_a
    end
    
    def binary?
      !! @binary
    end
    
  end
  
end
