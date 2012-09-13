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
SEND_MAIL = ENV["SEND_MAIL"] == "true"
if SEND_MAIL
  smtp_settings = {
    address: ENV["MAIL_HOST"],
    port: ENV["MAIL_PORT"],
    authentication: ENV["MAIL_AUTHENTICATION"].to_sym,
    user_name: ENV["MAIL_USERNAME"],
    password: ENV["MAIL_PASSWORD"]
  }
  if ENV["MAIL_SSL"] == "true"
    smtp_settings.merge tls: true, enable_starttls_auto: true
  end

  ActionMailer::Base.smtp_settings = smtp_settings
end

require './db/database'

config = { dburl: ENV["DB_URL"] }

setup_db(config)
