module Mercurial
  
  class Commit
    include Mercurial::Helper
    
    attr_reader :repository, :hash_id, :author, :author_email,
                :date, :message, :files_changed, :files_added,
                :files_deleted, :branches_names, :tags_names,
                :parents
    
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
      @parents        = parents_to_array(opts[:parents])
    end
    
    def merge?
      parents.size > 1
    end
    
    def diff
      hg("diff -c#{ hash_id }")
    end
    
  protected
  
    def to_files_array(string)
      if string
        string.split(';')
      else
        []
      end
    end
    
    def parents_to_array(string)
      if string && !string.empty?
        [].tap do |returning|
          string.split(' ').map do |hg_hash|
            returning << hg_hash_to_hash_id(hg_hash)
          end
        end
      else
        []
      end
    end
    
    def hg_hash_to_hash_id(hg_hash)
      hg_hash.split(':').last
    end
    
  end
  
end