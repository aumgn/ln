require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/json'
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
  @new_link = ShortenedLink.create(name: params[:name],
      url: params[:url], user: current_user)
  slim :index
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

get '/admin' do
  halt 403 if current_user.nil? || !current_user.admin
  slim :admin
end

link = %r{^/([0-9a-zA-Z]+)$}

get link do
  link = ShortenedLink.first name: params[:captures]
  raise(Sinatra::NotFound) if link.nil?
  link.update clicks: link.clicks + 1
  redirect link.url
end

put link do
  halt(403) if current_user.nil?
  link = ShortenedLink.first name: params[:captures]
  raise(Sinatra::NotFound) if link.nil?
  halt(403) if !current_user.admin && current_user != link.user
  updates = {}
  updates[:clicks] = 0 if params[:reset] = "1"
  updates[:url] = params[:url] if params[:url]
  link.update(updates);
  json link.errors.to_a
end

delete link do
  link = ShortenedLink.first name: params[:captures]
  halt(403) if current_user.nil?
  raise(Sinatra::NotFound) if link.nil?
  halt(403) if !current_user.admin && current_user != link.user
  json link.destroy ? [] : ["Unable to delete link #{link.name}."]
end
