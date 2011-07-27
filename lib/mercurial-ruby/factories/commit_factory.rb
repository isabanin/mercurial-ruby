module Mercurial
  
  class CommitFactory
    
    TEMPLATE_SEPARATOR = '|><|'
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      [].tap do |returning|
        hg("log --template \"#{ template }\n\"").split("\n").each do |data|
          returning << build_from_cl_data(data)
        end
      end
    end
    
    def by_branch(branch)
      [].tap do |returning|
        hg("log -b #{ branch} --template \"#{ template }\n\"").split("\n").each do |data|
          returning << build_from_cl_data(data)
        end
      end
    end
    
    def by_hash_id(hash)
      data = hg("log -r#{ hash } --template \"#{ template }\"")
      unless data.empty?
        build_from_cl_data(data)
      end
    end
    
  protected
  
    def build_from_cl_data(data)
      data = data.split(TEMPLATE_SEPARATOR)
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
  
    def template
      # DO NOT REORDER
      [
        'node', 'author|person', 'author|email',
        'date|date', 'desc', 'files', 'files_adds',
        'files_dels', 'branches', 'tags'
      ].map{|t| "{#{ t }}"}.join(TEMPLATE_SEPARATOR)
    end
  
    def hg(cmd)
      Mercurial::Shell.hg(cmd, :in => repository.path)
    end
    
  end
  
end