require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'machinist/active_record'
require 'sham'
require 'faker'

require 'ca_ching'

Dir[File.expand_path('../{helpers,support,blueprints}/*.rb', __FILE__)].each do |f|
  require f
end

Sham.define do
  name     { Faker::Name.name }
  title    { Faker::Lorem.sentence }
  body     { Faker::Lorem.paragraph }
  salary   {|index| 30000 + (index * 1000)}
  note     { Faker::Lorem.words(7).join(' ') }
  tag_name { Faker::Lorem.words(3).join(' ') }
end

RSpec.configure do |config|
  CaChing.configure do |config|
    config.cache = CaChing::Adapters::Redis.new(:host => 'localhost', :port => 6379)
  end
  
  config.before(:suite) do
    Schema.create
  end
  
  config.before(:all) { Sham.reset(:before_all) }
  config.before(:each) { Sham.reset(:before_each) }
end