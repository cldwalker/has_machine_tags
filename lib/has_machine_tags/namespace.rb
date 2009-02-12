module HasMachineTags
  class Namespace
    def initialize(name)
      @name = name.to_s
    end

    def tags
      @tags ||= Tag.find_all_by_namespace(@name)
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

    def outline_view
      body = [@name]
      level_delim = "\t"
      predicate_map.each do |pred, vals|
        body << [level_delim + pred]
        body += vals.map {|e| level_delim * 2 + e}
      end
      body.join("\n")
    end

    def inspect
      outline_view
    end
  end
end
