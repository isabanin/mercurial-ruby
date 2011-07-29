module Mercurial
  
  class Commit
    include Mercurial::Helper
    
    attr_reader :repository, :hash_id, :author, :author_email,
                :date, :message, :changed_files,
                :branches_names, :tags_names, :parents_ids
    
    def initialize(repository, opts={})
      @repository     = repository
      @hash_id        = opts[:hash_id]
      @author         = opts[:author]
      @author_email   = opts[:author_email]
      @date           = Time.parse(opts[:date])
      @message        = opts[:message]
      @changed_files  = files_to_array(opts[:changed_files])
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
  
    def files_to_array(array)
      [].tap do |returning|
        array.each do |files|
          if files
            files.split(';').map do |file_with_mode|
              mode = mode_letter_to_word(file_with_mode[0..0])
              source = file_with_mode.split('->').first[2..-1]
              name = file_with_mode.split('->')[1]
              returning << [
                source,
                mode,
                name
              ].compact
            end
          end
        end
      end
    end
    
    def parents_to_array(string)
      if string && !string.empty?
        [].tap do |returning|
          string.split(' ').map do |hg_hash|
            returning << hg_hash_to_hash_id(hg_hash)
          end
        end
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
      when 'C'
        :copy
      else
        :edit
      end
    end
    
  end
  
end