module CaChing
  module Query
    class Abstract      
      # Unceremoniously taken from cache-money
      AND = /\s+AND\s+/i
      TABLE_AND_COLUMN = /(?:(?:`|")?(\w+)(?:`|")?\.)?(?:`|")?(\w+)(?:`|")?/   # Matches: `users`.id, `users`.`id`, users.id, id
      VALUE = /'?(\d+|\?|(?:(?:[^']|'')*))'?/                                  # Matches: 123, ?, '123', '12''3'
      KEY_EQ_VALUE = /^\(?#{TABLE_AND_COLUMN}\s+=\s+#{VALUE}\)?$/              # Matches: KEY = VALUE, (KEY = VALUE)
      ORDER = /^#{TABLE_AND_COLUMN}\s*(ASC|DESC)?$/i                           # Matches: COLUMN ASC, COLUMN DESC, COLUMN
      
      def initialize(active_record_collection, options={})
        self.tap do
          @collection = active_record_collection
          @sql = object.to_sql
        end
      end
      
      def table_name
        @collection.table_name
      end
      
      def where
        @collection.where_values.inject({}) do |hash, value|
          if value.respond_to? :left
            left = value.left.name
            right = value.right
            if right == '?'
              right = @collection.bind_values.find { |value| value.name == left }[1]
            end
            
            hash[left] = ['=', right]
          else
            value.split(AND).each do |value|
              match = KEY_EQ_VALUE.match(value).captures
              left, right = match[1], match[2]
              
              hash[left] = ['=', right]
            end
          end
          
          hash
        end
      end
      
      def order
        @collection.order_values.inject({}) do |hash, value|
          value.split(',').each do |value|
            match = ORDER.match(value).captures
            hash[match[1]] = match[2]
          end
          
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
      
      def cacheable?
        !!(@collection.to_sql =~ /OR/)
      end
    end
  end
end