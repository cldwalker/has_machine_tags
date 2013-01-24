module HasMachineTags
  module Finder
    # Takes a string of delimited tags or an array of tags.
    # Note that each tag is interpreted as a possible wildcard machine tag.
    # 
    # Options:
    #   :conditions - A piece of SQL conditions to add to the query.
    #
    # Example:
    #  Url.tagged_with 'something' # => fetches urls tagged with 'something'
    #  Url.tagged_with 'gem:'      # => fetches urls tagged with tags that have namespace gem
    #  Url.tagged_with 'gem, something' # =>  fetches urls that are tagged with 'something'
    #    or 'gem'
    #   
    #  Note: This method really only needs to be used with Rails < 2.1 . 
    #  Rails 2.1 and greater should use tagged_with(), which acts the same but with
    #  the benefits of named_scope.
    #
    def find_tagged_with(*args)
      options = find_options_for_tagged_with(*args)
      options.blank? ? [] : find(:all, options)
    end

    # :stopdoc:
    def find_options_for_tagged_with(tags, options = { })
      tags = TagList.new(tags)
      return { } if tags.empty?
      conditions = []
      conditions << sanitize_sql(options.delete(:conditions)) if options[:conditions]
      conditions << condition_from_tags(tags, options)
      options.delete(:match_all)
      default_find_options_for_tagged_with.update(:conditions=>conditions.join(" AND ")).update(options)
    end

    def condition_from_tags(tags, options = { })
      options[:match_all] ? match_all_tags_sql(tags) : match_any_tag_sql(tags)
    end

    def match_any_tag_sql(tags)
      tag_sql = tags.map { |t|
        if match = Tag.match_wildcard_machine_tag(t)
          string = match.map { |k, v|
            sanitize_sql(["#{tags_alias}.#{k} = ?", v])
          }.join(" AND ")
          "(#{string})"
        else
          sanitize_sql(["#{tags_alias}.name = ?", t])
        end
      }.join(" OR ")
    end

    def match_all_tags_sql(tags)
      tag_sql = tags.map { |t|
        # Create sub-requests returning taggable IDs being tagged by each tag
        string = "SELECT #{taggings_alias}.taggable_id FROM #{Tagging.table_name} #{taggings_alias} " +
                 "LEFT JOIN #{Tag.table_name} #{tags_alias} ON #{taggings_alias}.tag_id = #{tags_alias}.id " +
                 "WHERE #{taggings_alias}.taggable_type = #{quote_value(base_class.name)} AND ("

        if match = Tag.match_wildcard_machine_tag(t)
          string += match.map { |k, v|
            sanitize_sql(["#{tags_alias}.#{k} = ?", v])
          }.join(" AND ") + ")"
        else
          string += "#{sanitize_sql(["#{tags_alias}.name = ?", t])})"
        end

        string
      }.reverse.reduce("") { |sql, request|
        # Each sub-request operates on the results of its inner one, intersecting all taggable ids to end up
        # with a list of ids representing the taggables that are tagged with ALL provided tags
        # (INTERSECT is not understood by MySQL...)
        sql.empty? ? request : "#{request} AND #{taggings_alias}.taggable_id IN (#{sql})"
      }

      # Return the whole condition set
      "#{table_name}.#{primary_key} IN (#{tag_sql})"
    end

    def taggings_alias
      "#{table_name}_taggings"
    end

    def tags_alias
      "#{table_name}_tags"
    end

    def default_find_options_for_tagged_with
      { :select => "DISTINCT #{table_name}.*",
        :joins => "LEFT OUTER JOIN #{Tagging.table_name} #{taggings_alias} ON #{taggings_alias}.taggable_id = #{table_name}.#{primary_key} AND #{taggings_alias}.taggable_type = #{quote_value(base_class.name)} " +
            "LEFT OUTER JOIN #{Tag.table_name} #{tags_alias} ON #{tags_alias}.id = #{taggings_alias}.tag_id",
        # :group      => group
      }
    end

    # TODO: add back in options as needed.
    # Options:
    #   :exclude - Find models that are not tagged with the given tags.
    #   :match_all - Find models that match all of the given tags, not just one (doesn't work with machine tags yet).
    def old_find_options_for_find_tagged_with(tags, options = { }) #:nodoc:
                                                                   # options.reverse_merge!(:match_all=>true)
      machine_tag_used = false
      if options.delete(:exclude)
        tags_conditions = tags.map { |t| sanitize_sql(["#{Tag.table_name}.name = ?", t]) }.join(" OR ")
        conditions << sanitize_sql(["#{table_name}.id NOT IN (SELECT #{Tagging.table_name}.taggable_id FROM #{Tagging.table_name} LEFT OUTER JOIN #{Tag.table_name} ON #{Tagging.table_name}.tag_id = #{Tag.table_name}.id WHERE (#{tags_conditions}) AND #{Tagging.table_name}.taggable_type = #{quote_value(base_class.name)})", tags])
      else
        conditions << condition_from_tags(tags)

        if options.delete(:match_all)
          group = "#{taggings_alias}.taggable_id HAVING COUNT(#{taggings_alias}.taggable_id) = "
          if machine_tag_used
            #Since a machine tag matches multiple tags per given tag, we need to dynamically calculate the count
            #TODO: this select needs to return differently for each taggable_id
            group += "(SELECT count(id) FROM #{Tag.table_name} #{tags_alias} WHERE #{tag_sql})"
          else
            group += tags.size.to_s
          end
        end
      end
      default_find_options_for_tagged_with.update(:conditions=>conditions.join(" AND ")).update(options)
    end
    # :startdoc:
  end
end