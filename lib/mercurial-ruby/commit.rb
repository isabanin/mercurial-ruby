module Mercurial
  
  class Commit
    
    attr_reader :repository, :hash_id, :author, :author_email,
                :date, :message, :files_changed, :files_added,
                :files_deleted, :branches_names, :tags_names
    
    def initialize(repository, opts={})
      @repository     = repository
      @hash_id        = opts[:hash_id]
      @author         = opts[:author]
      @author_email   = opts[:author_email]
      @date           = Time.parse opts[:date]
      @message        = opts[:message]
      @files_changed  = to_files_array(opts[:files_changed])
      @files_added    = to_files_array(opts[:files_added])
      @files_deleted  = to_files_array(opts[:files_deleted])
      @branches_names = opts[:branches_names]
      @tags_names     = opts[:tags_names]
    end
    
    def diff
      Mercurial::Shell.hg("diff -c#{ hash_id }", :in => repository.path)
    end
    
  protected
  
    def to_files_array(string)
      if string
        string.split(';')
      else
        []
      end
    end
    
  end
  
end