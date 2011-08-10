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
    
    def by_hash_ids(*args)
      if args.size == 1 && args.first.kind_of?(Array)
        array = args.first
      else
        array = args
      end      
      return [] if array.empty?

      args = array.map{|hash| " -r#{ hash }"}
      hg_to_array "log#{ args } --style #{ style }" do |line|
        build(line)
      end
    end
    
    def for_range(hash_a, hash_b)
      hg_to_array "log -r #{ hash_a }:#{ hash_b } --style #{ style }" do |line|
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
      commit = Mercurial::Commit.new(
        repository,
        :hash_id         => data[0],
        :author          => data[1],
        :author_email    => data[2],
        :date            => data[3],
        :message         => data[4],
        :changed_files   => [data[5], data[6], data[7], data[8]],
        :branches_names  => data[9],
        :tags_names      => data[10],
        :parents         => data[11]
      )
      
      if commit.blank?
        nil
      else
        commit
      end
    end
  
    def style
      Mercurial::Style.changeset
    end
    
  end
  
end