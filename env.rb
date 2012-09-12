##################
## Dependencies ##
##################
require 'bundler/setup'

RACK_ENV = ENV["RACK_ENV"] || :development
USE_SSL = ENV["USE_SSL"] == "true"
Bundler.require(:default, RACK_ENV)

###########
## Setup ##
###########
require './db/database'

config = { dburl: ENV["DB_URL"] }

setup_db(config)
