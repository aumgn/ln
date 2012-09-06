def setup_db(config)
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, config["pgurl"])

  require './db/user'
  require './db/shortened_link.rb'

  DataMapper.finalize
  DataMapper.auto_upgrade!
end
