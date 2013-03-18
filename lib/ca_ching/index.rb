module CaChing
  module Index
    extend ActiveSupport::Concern
    
    VALID_OPTIONS = [:order, :ttl, :limit]
    
    module ClassMethods
      def index(field_name, options={})
        raise CaChing::InvalidOptionError unless options.keys.inject(true) { |flag, key| flag && CaChing::Index::VALID_OPTIONS.include?(key) } 
        indexed_fields[field_name] = options
      end
      
      def indexes?(field_name)
        indexed_fields.has_key?(field_name)
      end
      
      def indexed_fields
        @_indexed_fields ||= {}
      end
    end
    
    def indexed_fields
      self.class.indexed_fields
    end
  end
end
