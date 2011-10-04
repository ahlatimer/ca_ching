# CaChing

CaChing is a write-through and read-through caching library for ActiveRecord. 

That means that when you read from the database, your results are stored in the cache (read-through). When you write to
the database, whatever is written to the database is also written to the cache (write-through). If the results are already
in the cache, great, they're read straight from there on a read, and updated on a write. 

## Getting started

In your Gemfile:

    gem 'ca_ching'
    # gem 'ca_ching', :git => 'git://github.com/ahlatimer/ca_ching.git' # Track git repo

In an initializer:
    
    CaChing.configure do |config|
      # some configuration options go here, likely just for redis...
    end
    
## Defining what to cache

The simplest case is to add `index :field_name` to your model. From then on, any query that does a find based on
that field will get cached. You can also specify the maximum number of elements stored, the TTL (time to live),
and the order. 

    class Person < ActiveRecord::Base
      index :id
      index :first_name, :limit => 1000
      index :last_name,  :limit => 1000
      index :created_at, :order => :desc
      
      has_many :addresses
    end
    
    class Address < ActiveRecord::Base  
      # You can have associations, so person.addresses.find(1) will hit the cache if a composite index is specified
      index [:id, :person_id], :limit => 100, :ttl => 10.minutes
      
      belongs_to :person
    end
    
## Using the cache

If you've defined your indices, everything should work without any additional effor. Doing 
`Person.where(:first_name => 'Andrew')` should hit the cache and return what is there, or 
miss and pull the data into the cache. 

## Queries supported

Generally anything with an `AND` and/or `eqality` is supported by CaChing. Anything including
joins, includes, `OR`, and inequality (!=) are not supported at this time. Queries involving
comparators (>, <, >=, <=) are supported ONLY if the order is specified. The caveats for order
(covered below) apply here as well. 

For example, these queries are supported:

    Person.where(:first_name => 'Andrew')
    Person.find_by_first_name('Andrew')
    Person.where('created_at >= ?', Date.today - 1)
    Person.where('created_at <= ?', Date.today - 1).where(:first_name => 'Andrew').limit(10).order('created_at desc')

These queries are not:
    
    Person.where('first_name = ? OR first_name = ?', 'Andrew', 'David')
    Person.where('first_name != ?', 'Andrew')
    Person.where(:first_name => 'Andrew').order('created_at desc')
    Person.where('id >= 200')
     
## Caveats

### Order

If the order in the query is not the same as the order in the index directive, the cache will be skipped. 
It's likely faster to take the DB hit than to try to sort in Ruby. 

If multiple fields are specified, at least one of them must have the order of the query. 

If the field is sorted, it must respond to `to_f` and return a reasonable response (e.g., even though a 
string will respond to `to_f`, it will return `0.0` if it is not a number). 