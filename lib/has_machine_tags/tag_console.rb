module HasMachineTags
  # Provides named_scopes and class methods to the Tag model, useful in machine tag analysis from the console.
  # To use:
  #   class Tag
  #     include HasMachineTags::TagConsole
  #   end
  module TagConsole
    def self.included(base) #:nodoc:
      scope = Rails.version >= '3.0' ? 'scope' : 'named_scope'
      base.class_eval %[
        self.#{scope} :namespace_counts, :select=>'*, namespace as counter, count(namespace) as count', :group=>"namespace HAVING count(namespace)>=1"
        self.#{scope} :predicate_counts, :select=>'*, predicate as counter, count(predicate) as count', :group=>"predicate HAVING count(predicate)>=1"
        self.#{scope} :value_counts, :select=>'*, value as counter, count(value) as count', :group=>"value HAVING count(value)>=1"
        self.#{scope} :distinct_namespaces, :select=>"distinct namespace"
        self.#{scope} :distinct_predicates, :select=>"distinct predicate"
        self.#{scope} :distinct_values, :select=>"distinct value"
      ]
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Array of words in namespace field
      def namespaces; distinct_namespaces.map(&:namespace).compact; end
      # Array of words in predicate field
      def predicates; distinct_predicates.map(&:predicate).compact; end
      # Array of words in value field
      def values; distinct_values.map(&:value).compact; end
    end
  end
end
