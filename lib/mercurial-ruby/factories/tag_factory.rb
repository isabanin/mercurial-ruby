module Mercurial
  
  class TagFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
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
      return if name == 'tip'
      Mercurial::Tag.new(repository, name, hash_id)
    end

  end
  
end