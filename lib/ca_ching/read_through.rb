require 'ca_ching/query/abstract'
require 'ca_ching/query/calculation'
require 'ca_ching/query/select'

module CaChing
  module ReadThrough
    extend ActiveSupport::Concern
    
    module ClassMethods
    end
    
    # All queries, be they find(id), dynamic finders (find_by_foo, find_all_by_foo, etc.),
    # where(:foo => :bar), order('foo DESC'), etc. go through to_a before being returned.
    # Hook into that point to check the cache. 
    def to_a_with_cache
      @_query = CaChing::Query::Select.new(self)
      
      return to_a_without_cache if CaChing.cache.nil? || CaChing.disabled? || !cacheable?
      
      result = CaChing.cache.find(@_query)
      @from_cache = true
      
      if result.nil?
        result = to_a_without_cache
        CaChing.cache.insert(result, :for => @_query)
        @from_cache = false
      end
      
      result.from_cache = self.from_cache?
      result.each { |item| item.from_cache = self.from_cache? }
      
      return result
    end 
    
    def from_cache?
      @from_cache ||= false
    end
    
    def cacheable?
      unsupported_methods = [:from_value,
                             :group_values,
                             :having_values,
                             :includes_values,
                             :joined_includes_values,
                             :joins_values,
                             :lock_value,
                             :select_values,
                             :order_values]
      !where_values.empty? && find_on_indexed_fields? && unsupported_methods.inject(true) { |flag, method| self.send(method).send(method.to_s =~ /values/ ? :empty? : :nil?) && flag }
    end
    
    private
    def find_on_indexed_fields?
      (@_query.where.keys - indexed_fields.keys).empty?
    end
    
    included do |base|
      base.class_eval do
        alias_method_chain :to_a, :cache
      end
    end
  end
end
