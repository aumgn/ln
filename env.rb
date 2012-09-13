##################
## Dependencies ##
##################
require 'bundler/setup'

RACK_ENV = ENV["RACK_ENV"] || :development
Bundler.require(:default, RACK_ENV)

###########
## Setup ##
###########
BASE_URL = ENV["BASE_URL"]
USE_SSL = ENV["USE_SSL"] == "true"

SEND_MAIL = ENV["SEND_MAIL"] == "true"
if SEND_MAIL
  smtp = {
    address: ENV["MAIL_HOST"],
    port: ENV["MAIL_PORT"],
    authentication: ENV["MAIL_AUTHENTICATION"].to_sym,
    user_name: ENV["MAIL_USERNAME"],
    password: ENV["MAIL_PASSWORD"]
  }
  if ENV["MAIL_SSL"] == "true"
    smtp.merge tls: true, enable_starttls_auto: true
  end

  Pony.options = {
    via: :smtp,
    via_options: smtp,
    from: ENV["MAIL_SENDER"]
  }
end

require './db/database'

config = { dburl: ENV["DB_URL"] }

setup_db(config)
