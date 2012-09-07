def setup_db(config)
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, config[:dburl])

  require './db/user'
  require './db/shortened_link.rb'

  DataMapper.finalize
end
