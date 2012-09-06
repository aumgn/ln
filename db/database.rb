def setup_db(config)
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, config["pgurl"])

  require './db/user'

  DataMapper.finalize
  DataMapper.auto_migrate!
end
