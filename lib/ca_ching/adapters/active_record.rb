
ActiveRecord::Base.send :include, CaChing::Index
ActiveRecord::Base.send :include, CaChing::WriteThrough
ActiveRecord::Relation.send :include, CaChing::ReadThrough
ActiveRecord::Relation.send :include, CaChing::WriteThrough

class ActiveRecord::Base
  attr_accessor :from_cache
  
  def from_cache?
    @from_cache ||= false
  end
end