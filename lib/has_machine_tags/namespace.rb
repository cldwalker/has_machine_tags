module HasMachineTags
  class TagGroup
    def initialize(name, options={})
      @name = name.to_s
      @options = options
    end
    
    def tags
      @tags ||= Tag.machine_tags(@name)
    end
    
    def predicates
      tags.map(&:predicate)
    end

    def values
      tags.map(&:value)
    end

    def predicate_map
      tags.map {|e| [e.predicate, e.value] }.inject({}) {
        |t, (k,v)| (t[k] ||=[]) << v; t
      }
    end
    alias :pm :predicate_map
    
    def value_count(pred,value)
      Url.tagged_with("#{@name}:#{pred}=#{value}").count
    end
    
    def pred_count(pred)
      (predicate_map[pred] ||[]).map {|e| [e, value_count(pred, e)]}
    end
    
    def group_pred_count(pred)
      pred_count(pred).inject({}) {|hash,(k,v)|
        (hash[v] ||= []) << k
        hash
      }
    end
    
    def sort_group_pred_count(pred)
      hash = group_pred_count(pred)
      hash.keys.sort.reverse.map {|e|
        [e, hash[e]]
      }
    end
    
    def predicate_view(pred, view=nil)
      if view == :group
        sort_group_pred_count(pred).map {|k,v|
          "#{k}: #{v.join(', ')}"
        }
      elsif view == :count
        pred_count(pred).map {|k,v|
          "#{k}: #{v}"
        }
      else
        nil
      end
    end
    
    def outline_view(type=nil)
      body = [@name]
      level_delim = "\t"
      predicate_map.each do |pred, vals|
        body << [level_delim + pred]
        values = predicate_view(pred, type) || vals
        body += values.map {|e|
            level_delim * 2 + e
        }
      end
      body.join("\n")
    end

    def inspect
      outline_view(@options[:view])
    end
  end
  
  class Namespace < TagGroup
    def tags
      @tags ||= Tag.find_all_by_namespace(@name)
    end
  end
end
