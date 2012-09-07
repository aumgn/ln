##################
## Dependencies ##
##################
require 'bundler/setup'

RACK_ENV = ENV["RACK_ENV"] || :development
Bundler.require(:default, RACK_ENV)

###########
## Setup ##
###########
require './db/database'

config = { dburl: ENV["DB_URL"] }

setup_db(config)
