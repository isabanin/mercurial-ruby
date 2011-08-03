module Mercurial
  
  class Diff
    
    attr_reader :commit, :hash_a, :hash_b, :file_a, :file_b, :body
    
    def initialize(commit, opts={})
      @commit = commit
      @hash_a = opts[:hash_a]
      @hash_b = opts[:hash_b]
      @file_a = opts[:file_a]
      @file_b = opts[:file_b]
      @body   = opts[:body]
      @binary = opts[:binary]
    end
    
    def file_name
      file_b || file_a
    end
    
    def binary?
      !! @binary
    end
    
  end
  
end