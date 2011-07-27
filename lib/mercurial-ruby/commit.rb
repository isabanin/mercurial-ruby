module Mercurial
  
  class Commit
    
    attr_reader :repository, :hash_id, :author, :author_email,
                :date, :message, :files_changed, :files_added,
                :files_deleted, :branches_names, :tags_names
    
    def initialize(repository, options={})
      @repository     = repository
      @hash_id        = options[:hash_id]
      @author         = options[:author]
      @author_email   = options[:author_email]
      @date           = Time.parse options[:date]
      @message        = options[:message]
      @files_changed  = options[:files_changed]
      @files_added    = options[:files_added]
      @files_deleted  = options[:files_deleted]
      @branches_names = options[:branches_names]
      @tags_names     = options[:tags_names]
    end
    
    def diff
      Mercurial::Shell.hg("diff -c#{ hash_id }", :in => repository.path)
    end
    
  end
  
end