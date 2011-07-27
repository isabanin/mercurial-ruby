module Mercurial
  
  class BranchFactory
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      [].tap do |returning|
        Mercurial::Shell.hg('branches -c', :in => repository.path).split("\n").each do |data|          
          returning << new_from_cl_data(data)
        end
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
    
  private
  
    def new_from_cl_data(data)
      name, last_commit, status = *data.scan(/([\w-]+)\s+\d+:(\w+)\s*\(*(\w*)\)*/).first
      Mercurial::Branch.new(
        repository,
        name,
        :commit => last_commit,
        :status => status
      )
    end

  end
  
end