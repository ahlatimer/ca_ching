Bundler.setup
require 'machinist/active_record'
require 'sham'
require 'faker'

Dir[File.expand_path('../../spec/{helpers,support,blueprints}/*.rb', __FILE__)].each do |f|
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

Schema.create unless ENV['SCHEMA'] == 'no'

require 'ca_ching'

