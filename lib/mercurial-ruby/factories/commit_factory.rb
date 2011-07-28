module Mercurial
  
  class CommitFactory
    include Mercurial::Helper
    
    attr_reader :repository
    
    def initialize(repository)
      @repository = repository
    end
    
    def all
      hg_to_array "log --style #{ style }" do |line|
        build(line)
      end
    end
    
    def each(&block)
      all.each do |commit|
        block.call(commit)
      end
    end
    
    def count
      hg_to_array "log --template \"{node}\n\"" do |line|
        line
      end.size
    end
    
    def by_branch(branch)
      hg_to_array "log -b #{ branch} --style #{ style }" do |line|
        build(line)
      end
    end
    
    def by_hash_id(hash)
      build do
        hg("log -r#{ hash } --style #{ style }")
      end
    end
    
    def by_hash_ids(array)
      return [] if array.empty?
      args = array.map{|hash| " -r#{ hash }"}
      hg_to_array "log#{ args } --style #{ style }" do |line|
        build(line)
      end
    end
    
    def tip
      build do
        hg("tip --style #{ style }")
      end
    end
    alias :latest :tip
    
  protected
  
    def build(data=nil, &block)
      data ||= block.call
      return if data.empty?
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
        :tags_names      => data[9],
        :parents         => data[10]
      )
    end
  
    def style
      Mercurial::Style.changeset
    end
    
  end
  
end