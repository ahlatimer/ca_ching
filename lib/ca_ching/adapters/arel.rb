module CaChing
  module Adapters
    module Arel
      # Parses the where values from Arel and returns
      # them in a format that is familiar to the rest of the
      # system.
      # 
      # @example
      #   people = Person.where(:name => 'Andrew')
      #   CaChing::Adapters::Arel.process_where_values(people.where_values)
      #   # => { :name => 'Andrew' }
      # 
      # @example
      #   people = Person.where('name = Andrew')
      #   CaChing::Adapters::Arel.process_where_values(people.where_values)
      #   # => { :name => 'Andrew' }
      #
      # @example
      #   people = Person.where('name = Andrew').where(:salary => 1000.0)
      #   CaChing::Adapters::Arel.process_where_values(people.where_values)
      #   # => { :name => 'Andrew', :salary => 1000.0 }
      def self.process_where_values(where_values)
        result = {}
        result = where_values.inject({}) do |result, value|
          
        end
      end
      
      # Parses the order values from Arel and returns
      # them in a format that is familiar to the rest of the
      # system.
      # 
      # @example
      #   people = Person.order('created_at ASC')
      #   CaChing::Adapters::Arel.process_order_values(people.order_values)
      #   # => { :created_at => :asc }
      def self.process_order_values(order_values)
        order_values.inject({}) do |result, value|
          value.split(',').each do |value|
            left, right = value.split(' ').reject(&:blank?)
            result[left.to_sym] = right.downcase == "asc" ? :asc : :desc
          end
          
          result
        end
      end
      
      # Returns the limit value passed.
      #
      # Not really needed because Arel just stores the Fixnum
      # for the limit value, but adding it to keep things uniform. 
      def self.process_limit_values(limit_values)
        limit_values
      end
      
      # Unceremoniously taken from cache-money
      AND = /\s+AND\s+/i
      TABLE_AND_COLUMN = /(?:(?:`|")?(\w+)(?:`|")?\.)?(?:`|")?(\w+)(?:`|")?/   # Matches: `users`.id, `users`.`id`, users.id, id
      VALUE = /'?(\d+|\?|(?:(?:[^']|'')*))'?/                                  # Matches: 123, ?, '123', '12''3'
      KEY_EQ_VALUE = /^\(?#{TABLE_AND_COLUMN}\s+=\s+#{VALUE}\)?$/              # Matches: KEY = VALUE, (KEY = VALUE)
      ORDER = /^#{TABLE_AND_COLUMN}\s*(ASC|DESC)?$/i                           # Matches: COLUMN ASC, COLUMN DESC, COLUMN
    end
  end
end