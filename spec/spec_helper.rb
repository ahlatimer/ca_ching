require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'ca_ching'

require 'fixtures/person'

RSpec.configure do |config|
  $cache = CaChing::Adapters::Redis.config(:host => 'localhost', :port => 6379)
end