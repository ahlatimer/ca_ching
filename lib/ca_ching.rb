require "ca_ching/version"

require 'redis'
require 'redis/connection/hiredis'

require 'ca_ching/configuration'

require 'ca_ching/read_through'
require 'ca_ching/write_through'
require 'ca_ching/index'

require 'ca_ching/errors'

require 'ca_ching/adapters/redis'
require 'ca_ching/adapters/active_record'

module CaChing
  extend Configuration
end