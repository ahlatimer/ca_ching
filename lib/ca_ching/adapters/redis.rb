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
      
      def find(query, options={})
        results = nil        
        # where_values in the form { :field => ['=', 'value'] }
        where_values = query.where
        keys = where_values.map { |where_value| "#{where_value[0]}#{where_value[1][0]}#{where_value[1][1]}" }
        
        offset = query.offset || 0
        limit = (query.limit || -1) + offset
        
        if keys.length == 1
          key = "#{query.table_name}:#{keys[0]}"
          return nil unless @cache.exists key # the key has never been added to the cache, so it's a miss
          
          results = @cache.zrange(key, offset, limit)
        else # needs an intersection
          intersection_key = "#{query.table_name}:#{keys.join "&"}"
          
          if @cache.exists intersection_key
            results = @cache.zrange(intersection_key, offset, limit)
          else
            return nil unless keys.inject(true) { |memo, key| @cache.exists("#{query.table_name}:#{key}") && memo }
            @cache.zinterstore intersection_key, *keys.map { |key| "#{query.table_name}:#{key}" }
            @cache.zrange(intersection_key, offset, limit)
            @cache.del(intersection_key) unless options[:store_key]
          end
        end
        
        inflate(results, :for => query)
      end
      
      def insert(objects, options={})
        query = options[:for]
        return nil if query.nil? || (where_values = query.where).length > 1
        
        where_value = query.where.first
        
        key = "#{query.table_name}:#{where_value[0]}#{where_value[1][0]}#{where_value[1][1]}"
        deflated = deflate_with_score(objects)
        
        deflated.each do |object_and_score|
          @cache.zadd key, *object_and_score
        end
      end

      def update(object, options={})
        
      end
      
      def destroy(object, options={})
        key = object_or_key.is_a?(String) ? object_or_key : object_or_key.to_key
        
        @cache.zrem(key)
      end
      
      def destroy_all(objects, options={})
        objects.each do |object|
          destroy(object, options)
        end
      end
      
      def clear!
        
      end
      
      def inflate(objects, options={})
        return nil if objects.nil?
        
        unless options[:for]
          return objects
        else
          objects.map do |object|
            obj = options[:for].klass.new
            attributes = ActiveSupport::JSON.decode(object)
            attributes.each do |attr, value|
              obj.send(:"#{attr}=", value)
            end
            obj
          end
        end
      end
      
      def deflate_with_score(objects, options={})
        return nil if objects.nil?
        
        objects.map { |object| [(object.try(:to_i) || 0), ActiveSupport::JSON.encode(object.attributes)] }
      end
      
      def method_missing(method_name, *args, &block)
        @cache.send method_name, *args, &block
      end
    end
  end
end