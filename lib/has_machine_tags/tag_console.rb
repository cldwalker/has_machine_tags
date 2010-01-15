module HasMachineTags
  module TagConsole #:nodoc:
    def self.included(base)
      base.class_eval %[
        named_scope :namespace_counts, :select=>'*, namespace as counter, count(namespace) as count', :group=>"namespace HAVING count(namespace)>=1"
        named_scope :predicate_counts, :select=>'*, predicate as counter, count(predicate) as count', :group=>"predicate HAVING count(predicate)>=1"
        named_scope :value_counts, :select=>'*, value as counter, count(value) as count', :group=>"value HAVING count(value)>=1"
        named_scope :distinct_namespaces, :select=>"distinct namespace"
        named_scope :distinct_predicates, :select=>"distinct predicate"
        named_scope :distinct_values, :select=>"distinct value"
      ]
      base.extend ClassMethods
    end
    
    module ClassMethods
      #:stopdoc:
      def namespaces; distinct_namespaces.map(&:namespace).compact; end
      def predicates; distinct_predicates.map(&:predicate).compact; end
      def values; distinct_values.map(&:value).compact; end
      #:startdoc:
    end
  end
end