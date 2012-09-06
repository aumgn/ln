require 'sinatra'
require 'sinatra/cookies'
require './env'

#############
## Helpers ##
#############
helpers do

  def current_user
    @current_user ||= find_current_user
  end

  def find_current_user
    token = cookies[:auth_token]
    return nil if token.nil?
    return User.first auth_token: token
  end
end

############
## Routes ##
############
get '/' do
  redirect("/login") if current_user.nil?
  slim :index
end

post '/' do
  redirect("/login") if current_user.nil?
  @link = ShortenedLink.create(name: params[:name],
      url: params[:url], user: current_user)
  slim :new_link
end

get '/login' do
  slim :login
end

post '/login' do
  user = User.authenticate(params[:email], params[:password])
  if user.nil?
    redirect "/login"
  else
    if params["remember"]
      default_expires = cookies.options[:expires]
      cookies.options[:expires] = Time.now + (60 * 24 * 60 * 60)
      cookies[:auth_token] = user.auth_token
      cookies.options[:expires] = default_expires
    else
      cookies[:auth_token] = user.auth_token
    end
    redirect '/'
  end
end

get '/logout' do
  cookies[:auth_token] = nil
  redirect '/login'
end

get '/links' do
  redirect "/login" if current_user.nil?
  slim :links
end

get '/admin' do
  halt 403 if current_user.nil? || !current_user.admin
  slim :admin
end

link = %r{^/([0-9a-zA-Z]+)$}

get link do
  link = ShortenedLink.first name: params[:captures]
  raise(Sinatra::NotFound) if link.nil?
  redirect link.url
end

delete link do
  link = ShortenedLink.first name: params[:captures]
  raise(Sinatra::NotFound) if link.nil?
  halt(403) if !current_user.admin && current_user != link.user
  link.destroy
  redirect "/links"
end
