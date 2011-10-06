
ActiveRecord::Base.send :include, CaChing::Index
ActiveRecord::Base.send :include, CaChing::Cache
ActiveRecord::Relation.send :include, CaChing::ReadThrough
