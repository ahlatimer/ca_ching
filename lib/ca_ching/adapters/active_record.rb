
ActiveRecord::Base.send :include, CaChing::Index
ActiveRecord::Base.send :include, CaChing::WriteThrough
ActiveRecord::Relation.send :include, CaChing::ReadThrough
ActiveRecord::Relation.send :include, CaChing::WriteThrough

class ActiveRecord::Base
  attr_accessor :from_cache
  
  def from_cache?
    @from_cache ||= false
  end
  
  def to_keys(options={})
    was = options[:old_values] ? "_was" : ""
    indexed_fields.map do |index, options|
      if index.is_a?(Array)
        self.class.table_name.to_s + index.map { |index| "#{index}=#{self.send("#{index}#{was}")}" }.join("&")
      else
        "#{self.class.table_name}:#{index}=#{self.send("#{index}#{was}")}"
      end
    end
  end
end