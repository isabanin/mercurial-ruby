module Mercurial
  
  class ChangedFile
    
    attr_reader :name, :initial_name
    attr_accessor :mode_letter
    
    def initialize(opts={})
      @initial_name = opts[:initial_name]
      @name         = enforce_unicode(opts[:name])
      @mode_letter  = opts[:mode]
    end
    
    def moved?
      mode == :move
    end
    
    def copied?
      mode == :copy
    end
    
    def deleted?
      mode == :delete
    end
    
    def added?
      mode == :add
    end
    
    def modified?
      mode == :edit
    end
    
    def mode
      case mode_letter
      when 'A'
        :add
      when 'D'
        :delete
      when 'C'
        :copy
      when 'R'
        :move
      else
        :edit
      end
    end

  private

    def enforce_unicode(str)
      str.encode('utf-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
    end

  end
  
end