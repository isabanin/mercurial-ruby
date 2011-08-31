module Mercurial
  
  class BranchFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      hg_to_array "branches -c" do |line|
        build(line)
      end
    end
    
    def active
      all.find_all do |b|
        b.active?
      end
    end
    
    def closed
      all.find_all do |b|
        b.closed?
      end
    end
    
    def by_name(name)
      all.find do |b|
        b.name == name
      end
    end
    
    def for_commit(hash_id)
      hg_to_array ["log -r 'descendants(?) and head()' --template '\n{branches}'", hash_id] do |line|
        build_with_name_only(line)
      end.compact.uniq
    end
    
  private
  
    def build(data)
      name, last_commit, status = *data.scan(/([\w-]+)\s+\d+:(\w+)\s*\(*(\w*)\)*/).first
      Mercurial::Branch.new(
        repository,
        name,
        :commit => last_commit,
        :status => status
      )
    end
    
    def build_with_name_only(name)
      name = 'default' if name == ''
      Mercurial::Branch.new(repository, name)
    end

  end
  
end