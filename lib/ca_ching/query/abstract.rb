module CaChing
  module Query
    class Abstract
      attr_accessor :where, :order, :limit
      
      def initialize(values)
        self.tap do
          values.each do |value_type, values|
            instance_variable_set "@#{value_type}", CaChing::Adapters::Arel.send(:"process_#{value_type}_values", values)
          end
        end
      end
    end
  end
end