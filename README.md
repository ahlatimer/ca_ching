# CaChing

CaChing is a write-through and read-through caching library for ActiveRecord 3.1+. 

That means that when you read from the database, your results are stored in the cache (read-through). When you write to
the database, whatever is written to the database is also written to the cache (write-through). If the results are already
in the cache, great, they're read straight from there on a read, and updated on a write. 

Take a look at `SPEC.md` for what's planned for v1.

## Getting started

In your Gemfile:

    gem 'ca_ching'
    # gem 'ca_ching', :git => 'git://github.com/ahlatimer/ca_ching.git' # Track git repo

In an initializer:
    
    CaChing.configure do |config|
      config.cache = CaChing::Adapters::Redis.new
      config.enabled = true # defaults to true
    end
    
## Defining what to cache

The simplest case is to add `index :field_name` to your model. From then on, any query that does a find based on
that field will get cached. 

    class Person < ActiveRecord::Base
      index :id
      index :first_name
      index :last_name
      
      has_many :addresses
    end
    
    class Address < ActiveRecord::Base  
      # Let's you find by associations (person.addresses.all)
      index :person_id
      
      belongs_to :person
    end
    
## Using the cache

If you've defined your indices, everything should work without any additional effort. Doing 
`Person.where(:first_name => 'Andrew')` should hit the cache and return what is there, or 
miss and pull the data into the cache. 

## Queries supported

Generally anything involving equality is supported by CaChing. Currently, only single fields can be found (e.g., `Person.where(:name => 'Andrew')` will be cached,
`Person.where(:name => 'Andrew', :age => 22)` is not). There is some plumbing for adding support for the latter, and support will be
introduced as soon as possible. I also have plans to add limited support for comparators (i.e., <, <=, >, >=).

Anything including joins, includes, `OR`, and inequality (!=) are not supported, nor do I have any plans for adding support. 

For example, these queries are supported:

    Person.where(:first_name => 'Andrew')
    Person.find_by_first_name('Andrew')
    Person.find_all_by_first_name('Andrew')

These queries are not:
    
    Person.where('first_name = ? OR first_name = ?', 'Andrew', 'David')
    Person.where('first_name != ?', 'Andrew')
    Person.where(:first_name => 'Andrew').order('created_at DESC') # not supported because first_name isn't sorted by anything
    Person.where('id >= 200')
    Person.where('created_at >= ?', Date.today - 1).where(:first_name => 'Andrew')
    Person.where('created_at <= ?', Date.today - 1).where(:first_name => 'Andrew').limit(10).order('created_at desc')
     
## Caveats

### Order

Order is not currently supported, although there will be some order functionality in the next version. 

### Composite keys and queries against multiple fields

Because of the awesomeness from Redis, composite keys aren't necessary for queries with multiple fields.
If all of the fields are indexed, CaChing will try to use the cache to build the results. 

Redis requires that sorted set intersections be stored in a resulting set. If the composite key is not specified 
for a query against those fields, that resulting set will be destroyed as soon as the results are read. If the 
composite key *is* specified, CaChing will keep the resulting set. 

While there is support for this in the Redis adapter, there isn't any support in the ActiveRecord ties as I haven't
decided how, exactly, I'd like to add this. 

### Thar be dragons

While I've tried to outline the issues here (and write failing specs for them), realize that this is
still very much alpha software. There are probably a number of unknown unknowns that I just haven't
uncovered yet. If you find them, please be sure to [let me know](http://github.com/ahlatimer/ca_ching/issues)!

## Ruby/Rails versions supported

Ruby 1.9.2 and Rails 3.1+ are officially supported. I try to stick to Ruby 1.8.7 syntax, so it may be supported, 
but use it with the understanding that you are doing so at your own risk.

## Patches and Issues

I'd love the help! If you find an issue, please report it on the [Github issues page](http://github.com/ahlatimer/ca_ching/issues).
If you fix an issue, please include a spec that illustrates the issue. If you submit a feature, include thorough specs. 
Don't bump up the version in your pull request. If you want to keep different versions in your fork, feel free, but
please do not include them in your pull request.  

## Acknowledgments

Inspired by (and a bit of code copied from) [Cache Money](http://github.com/ngmoco/cache-money).