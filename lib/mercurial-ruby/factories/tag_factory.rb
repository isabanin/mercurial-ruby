module Mercurial
  
  class TagFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def self.skip_tip_tag?
      # 
      # "hg tags" command usually return "tip" together with all the tags
      # Since it's not really a tag we prefer ignoring it.
      #
      true
    end
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      hg_to_array "tags" do |line|
        build(line)
      end
    end
    
    def by_name(name)
      all.find do |b|
        b.name == name
      end
    end
    
  private
  
    def build(data)
      name, hash_id = *data.scan(/([\w-]+)\s+\d+:(\w+)\s*/).first
      return if name == 'tip' && self.class.skip_tip_tag?
      Mercurial::Tag.new(repository, name, hash_id)
    end

  end
  
end