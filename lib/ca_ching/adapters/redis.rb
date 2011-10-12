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
        return nil if keys.empty?
        
        offset = query.offset || 0
        limit = (query.limit || -1) + offset
        
        if keys.length <= 1
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
            @cache.del(intersection_key) unless options[:keep_intersection]
          end
        end
        
        inflate(results, :for => query)
      end
      
      def insert(objects, options={})
        key = nil
        if options[:for]
          query = options[:for]
          if (where_values = query.where).length == 1
            where_value = query.where.first
            key = "#{query.table_name}:#{where_value[0]}#{where_value[1][0]}#{where_value[1][1]}"
          else
            nil
          end
        elsif options[:at]
          key = options[:at]
        end
        
        return nil if key.nil?
        
        deflated = deflate_with_score(objects)
        deflated.each do |object_and_score|
          @cache.zadd key, *object_and_score
        end
      
        objects
      end

      def update(object, options={})
        old_keys = object.to_keys(:old_values => true).select { |key| @cache.exists(key) }
        new_keys = object.to_keys(:old_values => false).select { |key| @cache.exists(key) }
        
        @cache.multi do
          old_keys.each do |key|
            destroy(object, :at => key, :old_values => true)
          end

          new_keys.each do |key|
            insert([object], :at => key)
          end
        end
      end
      
      def destroy(object, options={})
        @cache.zrem(options[:at], deflate(object, :old_values => options[:old_values]))
      end
      
      def clear!
        @cache.flushdb
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
            obj.changed_attributes.clear
            obj.send(:instance_variable_set, "@new_record", false)
            obj
          end
        end
      end
      
      def deflate(object, options={})
        attributes = if options[:old_values]
          object.attributes.keys.inject({}) do |attributes, key|
            attributes[key] = object.send(:"#{key}_was")
            attributes
          end
        else
          object.attributes
        end
        
        ActiveSupport::JSON.encode(attributes)
      end
      
      def deflate_with_score(objects, options={})
        return nil if objects.nil?
        
        score_method = options[:sorted_by] || :id
        
        objects.map { |object| [object.send(score_method).to_i, deflate(object)] }
      end
    end
  end
end