module HasMachineTags
  class TagList < Array #:nodoc:
    cattr_accessor :delimiter
    self.delimiter = ','
  
    def initialize(string_or_array)
      array = string_or_array.is_a?(Array) ? string_or_array : string_or_array.split(/\s*#{delimiter}\s*/)
      concat array
    end
  
    def to_s
      join("#{delimiter} ")
    end
  end
end