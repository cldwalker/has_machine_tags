#:stopdoc:
module HasMachineTags
  module Console
    module InstanceMethods
      def tag_add_and_remove(remove_list, add_list)
        self.class.transaction do
          tag_add_and_save(add_list)
          tag_remove_and_save(remove_list)
        end
      end

      def tag_add_and_save(*add_list)
        self.tag_list = self.tag_list + add_list
        self.save
        self.tag_list
      end

      def tag_remove_and_save(*remove_list)
        self.tag_list = self.tag_list - quick_mode_tag_list(remove_list)
        self.save
        self.tag_list
      end

      def tag_and_save(tag_list)
        self.tag_list = tag_list
        self.save
        self.tag_list
      end
    end
    
    module ClassMethods
      def tagged_with_count(*args)
        tagged_with(*args).count
      end

      def find_and_change_machine_tags(find_tags, options={})
        results = find_tags.is_a?(Array) ? find_tags : tagged_with(find_tags)
        namespace = results.select {|e| 
          nsp = e.tag_list.select {|f| break $1 if f =~ /^(\S+):/}
           break nsp if !nsp.empty?
          false
        }
        if namespace
          results.each {|e|
            new_tag_list = e.tag_list.map {|f|
              f.include?("#{namespace}:") ? f : "#{namespace}:#{f}"
            }
            p [e.id, e.tag_list, new_tag_list]
            if options[:save]
              e.tag_and_save(new_tag_list)
            end
          }
        else
          puts "no namespace detected"
        end
        nil
      end

      def find_and_regex_change_tags(find_tags, regex, substitution, options={})
        results = find_tags.is_a?(Array) ? find_tags : tagged_with(find_tags)
        results.each do |e|
          new_tag_list = e.tag_list.map {|f| f.gsub(regex, substitution)}
          p [e.id, e.tag_list, new_tag_list]
          if options[:save]
            e.tag_and_save(new_tag_list)
          end
        end
        nil
      end

      def find_and_change_tag(old_tag, new_tag)
        results = tagged_with(old_tag)
        results.each {|e| e.tag_add_and_remove(old_tag, new_tag)}
        puts "Changed tag for #{results.length} records"
      end
    end
  end
end