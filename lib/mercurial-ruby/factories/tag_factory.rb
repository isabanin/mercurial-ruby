module Mercurial
  
  class TagFactory
    
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
      [].tap do |returning|
        Mercurial::Shell.hg('tags', :in => repository.path).split("\n").each do |data|          
          returning << new_from_cl_data(data)
        end
      end.compact
    end
    
    def by_name(name)
      all.find do |b|
        b.name == name
      end
    end
    
  private
  
    def new_from_cl_data(data)
      name, hash_id = *data.scan(/([\w-]+)\s+\d+:(\w+)\s*/).first
      return if name == 'tip' && self.class.skip_tip_tag?
      Mercurial::Tag.new(repository, name, hash_id)
    end

  end
  
end