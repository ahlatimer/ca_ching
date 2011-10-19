module CaChing
  module WriteThrough
    extend ActiveSupport::Concern
    
    module ClassMethods
    end
    
    module InstanceMethods
      def save_with_cache(*)
        return save_without_cache if CaChing.cache.nil? || CaChing.disabled?
        
        CaChing.cache.update(self)
        save_without_cache
      end
      
      def save_with_cache!
        return save_without_cache! if CaChing.cache.nil? || CaChing.disabled?
        
        CaChing.cache.update(self)
        save_without_cache!
      end
      
      def destroy_with_cache(*)
        return destroy_without_cache if CaChing.cache.nil? || CaChing.disabled?
        
        CaChing.cache.destroy(self)
        destroy_without_cache
      end
    end
    
    included do |base|
      base.class_eval do
        alias_method_chain :save, :cache
        alias_method_chain :save!, :cache
        alias_method_chain :destroy, :cache
      end
    end
  end
end