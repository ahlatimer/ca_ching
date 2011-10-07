
ActiveRecord::Base.send :include, CaChing::Index
ActiveRecord::Base.send :include, CaChing::WriteThrough
ActiveRecord::Relation.send :include, CaChing::ReadThrough
ActiveRecord::Relation.send :include, CaChing::WriteThrough