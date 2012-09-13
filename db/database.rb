def setup_db(config)
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, config[:dburl])

  require './db/user'
  require './db/shortened_link'
  require './db/password_reset'
  require './db/password_reset_observer'

  DataMapper.finalize
end
