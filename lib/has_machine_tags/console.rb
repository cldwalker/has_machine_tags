module HasMachineTags
  # Methods for console/irb use.
  module Console
    module InstanceMethods
      # Removes first list, adds second list and saves changes.
      def tag_add_and_remove(remove_list, add_list)
        self.class.transaction do
          tag_add_and_save(add_list)
          tag_remove_and_save(remove_list)
        end
      end

      # Adds given list and saves.
      def tag_add_and_save(*add_list)
        self.tag_list = self.tag_list + current_tag_list(add_list)
        self.save
        self.tag_list
      end
      
      # Removes given list and saves.
      def tag_remove_and_save(*remove_list)
        self.tag_list = self.tag_list - current_tag_list(remove_list)
        self.save
        self.tag_list
      end
      
      # Resets tag_list to given tag_list and saves.
      def tag_and_save(tag_list)
        self.tag_list = tag_list
        self.save
        self.tag_list
      end
    end
    
    module ClassMethods
      # Updates items tagged with an old tag to use the given new tag in place of the old tag.
      def find_and_change_tag(old_tag, new_tag)
        results = tagged_with(old_tag)
        results.each {|e| e.tag_add_and_remove(old_tag, new_tag)}
        puts "Changed tag for #{results.length} records"
      end
    end
  end
end