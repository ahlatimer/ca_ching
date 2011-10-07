require 'ca_ching/query/abstract'
require 'ca_ching/query/calculation'
require 'ca_ching/query/select'

require 'pp'

module CaChing
  module ReadThrough
    extend ActiveSupport::Concern
    
    module ClassMethods
    end
    
    module InstanceMethods
      # All queries, be they find(id), dynamic finders (find_by_foo, find_all_by_foo, etc.),
      # where(:foo => :bar), order('foo DESC'), etc. go through to_a before being returned.
      # Hook into that point to check the cache. 
      def to_a_with_cache
        return to_a_without_cache if CaChing.cache.nil? 
        
        query = CaChing::Query::Select.new(self)
        result = CaChing.cache.find(query)
        @from_cache = true
        
        if result.nil?
          result = to_a_without_cache
          CaChing.cache.insert(result, :for => query)
          @from_cache = false
        end
        
        result.from_cache = self.from_cache?
        
        return result
      end
      
      def from_cache?
        @from_cache ||= false
      end
    end
    
    included do |base|
      base.class_eval do
        alias_method_chain :to_a, :cache
      end
    end
  end
end