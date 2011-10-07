# This is kind of useless because it just delegates
# everything to the redis gem, but I'm including it
# just in case I want to do some funky things in the
# future. 

module CaChing  
  module Adapters
    class Redis
      def initialize(options={})
        @cache = ::Redis.new(options)
      end
      
      def find(arguments={})
        
      end
      
      def insert(object, options={})
        
      end
      
      def delete(keys)
        
      end
      
      def clear!
        
      end
      
      def method_missing(method_name, *args, &block)
        @cache.send method_name, *args, &block
      end
    end
  end
end