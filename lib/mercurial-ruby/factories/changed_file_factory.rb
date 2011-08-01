module Mercurial
  
  class ChangedFileFactory
    
    FILE_COPY_SEPARATOR = '->'
    
    def self.new_from_hg(str)
      if str.include?(FILE_COPY_SEPARATOR)
        copied_file = str.split(FILE_COPY_SEPARATOR)
        initial_name = copied_file.first[2..-1]
        name = copied_file[1]
      else
        initial_name = nil
        name = str[2..-1]
      end

      Mercurial::ChangedFile.new(
        :initial_name => initial_name,
        :name         => name,
        :mode         => str[0..0]
      )
    end
    
    def self.delete_hg_artefacts(files)
      #
      # For unknown reason Mercurial post duplicated 
      # entries for moved and copied files. First as
      # a pair of A and D operations, then as C.
      #
      files.reverse.each do |file|
        if file.copied?
          add = files.find{|f| f.added? && f.name == file.name}
          delete = files.find{|f| f.deleted? && f.name == file.initial_name}

          if add && delete
            file.mode_letter = 'R'
            files.delete_at(files.index(add))
            files.delete_at(files.index(delete))

          elsif add
            files.delete_at(files.index(add))
          end
        end
      end
      files
    end
    
  end
  
end