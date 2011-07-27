module Mercurial
  
  class CommitFactory
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      [].tap do |returning|
        hg("log --style #{ style }").split("\n").each do |data|
          returning << build_from_cl_data(data)
        end
      end
    end
    
    def by_branch(branch)
      [].tap do |returning|
        hg("log -b #{ branch} --style #{ style }").split("\n").each do |data|
          returning << build_from_cl_data(data)
        end
      end
    end
    
    def by_hash_id(hash)
      data = hg("log -r#{ hash } --style #{ style }")
      unless data.empty?
        build_from_cl_data(data)
      end
    end
    
  protected
  
    def build_from_cl_data(data)
      data = data.split(Mercurial::Style::TEMPLATE_SEPARATOR)
      Mercurial::Commit.new(
        repository,
        :hash_id         => data[0],
        :author          => data[1],
        :author_email    => data[2],
        :date            => data[3],
        :message         => data[4],
        :files_changed   => data[5],
        :files_added     => data[6],
        :files_deleted   => data[7],
        :branches_names  => data[8],
        :tags_names      => data[9]
      )
    end
  
    def style
      Mercurial::Style.changeset
    end
  
    def hg(cmd)
      Mercurial::Shell.hg(cmd, :in => repository.path)
    end
    
  end
  
end