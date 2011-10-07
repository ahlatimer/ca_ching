module CaChing
  module Query
    class Abstract      
      # Unceremoniously taken from cache-money
      AND = /\s+AND\s+/i
      OR  = /\s+OR\s+/i
      TABLE_AND_COLUMN = /(?:(?:`|")?(\w+)(?:`|")?\.)?(?:`|")?(\w+)(?:`|")?/   # Matches: `users`.id, `users`.`id`, users.id, id
      VALUE = /'?(\d+|\?|(?:(?:[^']|'')*))'?/                                  # Matches: 123, ?, '123', '12''3'
      KEY_CMP_VALUE = /^\(?#{TABLE_AND_COLUMN}\s+(=|<|<=|>|>=)\s+#{VALUE}\)?$/              # Matches: KEY = VALUE, (KEY = VALUE)
      ORDER = /^#{TABLE_AND_COLUMN}\s*(ASC|DESC)?$/i                           # Matches: COLUMN ASC, COLUMN DESC, COLUMN
      
      def initialize(active_record_collection, options={})
        self.tap do
          @collection = active_record_collection
          @sql = active_record_collection.to_sql
        end
      end
      
      def table_name
        @collection.table_name
      end
      
      def where
        raise UncacheableConditionError unless cacheable?
        
        @collection.where_values.inject({}) do |hash, value|
          if value.respond_to? :left
            left = value.left.name.to_sym
            right = value.right
            if right == '?'
              right = @collection.bind_values.find { |value| value.name == left }[1]
            end
            
            hash[left] = ['=', right]
          else
            value.split(AND).each do |value|
              match = KEY_CMP_VALUE.match(value).captures
              left, comparator, right = match[1].to_sym, match[2], match[3]
              
              hash[left] = [comparator, right]
            end
          end
          
          hash
        end
      end
      
      def order
        order_values = @collection.order_values.map { |v| v.split(',').map { |v| v.strip } }.flatten
        
        order_values.inject({}) do |hash, value|
          match = ORDER.match(value).captures
          hash[match[1].to_sym] = match[2] == "ASC" ? :asc : :desc
          
          hash
        end
      end
      
      def limit
        @collection.limit_value
      end
      
      def offset
        @collection.offset_value
      end
      
      def calculation?
        false
      end
      
      # Formats the query to a key for the value store. Takes the form 
      # table_name:encode(field1, [operator1, value1])&encode(field2, [operator2, value2])...
      def to_key
        "#{table_name}:#{where.map { |field, operator_and_value| encode(field, operator_and_value) } * "&" }"
      end
      
      private
      # Encodes string to the form "field_name=value" where '=' can be any arbitrary
      # operator. 
      #
      # @example
      #   encode('name', ['=', 'Andrew']) # => "name='Andrew'"
      # 
      # @example
      #   encode('age', ['>=', 21]) # => "age>=21"
      def encode(field, operator_and_value)
        operator, value = operator_and_value
        "#{field}#{operator}\"#{value.to_s.gsub('"', '\"')}\""
      end
      
      def cacheable?
        !(@collection.to_sql =~ OR)
      end
    end
    
    class UncacheableConditionError < StandardError; end
  end
end