##################
## Dependencies ##
##################
require 'bundler/setup'
Bundler.require(:default)

###########
## Setup ##
###########
require './db/database'

config = YAML.load_file("./config.yml")

setup_db(config)
