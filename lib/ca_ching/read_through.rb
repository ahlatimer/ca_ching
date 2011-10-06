require 'ca_ching/query/abstract'
require 'ca_ching/query/calculation'
require 'ca_ching/query/primary_key'
require 'ca_ching/query/select'

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
        
        query = CaChing::Query::Select.new(:where => self.where_values, :order => self.order_values, :limit => self.limit_value)
        result = CaChing.cache.find(query)
        
        if result.nil?
          result = to_a_without_cache
          CaChing.cache.insert(result, :for => query)
        end
        
        return result
      end
    end
    
    included do |base|
      base.class_eval do
        alias_method_chain :to_a, :cache
      end
    end
  end
end