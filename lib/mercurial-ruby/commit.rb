module Mercurial
  
  class Commit
    include Mercurial::Helper
    
    attr_reader :repository, :hash_id, :author, :author_email,
                :date, :message, :files_changed, :files_added,
                :files_deleted, :branches_names, :tags_names,
                :parents_ids
    
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
      @parents_ids    = parents_to_array(opts[:parents])
    end
    
    def merge?
      parents.size > 1
    end
    
    def diffs
      repository.diffs.for_commit(self)
    end
    
    def parents
      repository.commits.by_hash_ids(parents_ids)
    end
    
    def parent_id
      parents_ids.first
    end
    
  protected
  
    def to_files_array(string)
      if string
        string.split(';').map do |file_with_mode|
          [file_with_mode[2..-1], mode_letter_to_word(file_with_mode[0..0])]
        end
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
    
  private
  
    def mode_letter_to_word(letter)
      case letter
      when 'A'
        :add
      when 'D'
        :delete
      else
        :edit
      end
    end
    
  end
  
end