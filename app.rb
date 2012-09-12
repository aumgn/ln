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

  def use_ssl?
    USE_SSL
  end

  def secure_url(url)
    url.gsub("http://", "https://")
  end

  def secure_only
    if use_ssl? && !request.ssl?
      redirect secure_url(request.url)
    end
  end

  def logged_only
    secure_only
    scheme = use_ssl? ? "https://" : "http://"
    redirect(scheme + request.host_with_port + "/login") if current_user.nil?
  end

  def link_for(name)
    link = ShortenedLink.first name: name
    raise(Sinatra::NotFound) if link.nil?
    return link
  end

  def authorized_link_for(name)
    secure_only
    halt(403) if current_user.nil?
    link = link_for name
    raise Sinatra::NotFound if !current_user.admin && current_user != link.user
    return link
  end
end

############
## Routes ##
############
get '/' do
  logged_only
  slim :index
end

post '/' do
  logged_only
  @new_link = ShortenedLink.create(name: params[:name],
      url: params[:url], user: current_user)
  slim :index
end

get '/login' do
  secure_only
  slim :login
end

post '/login' do
  secure_only
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
  logged_only
  cookies[:auth_token] = nil
  redirect '/login'
end

link = %r{^/([0-9a-zA-Z]+)$}

get link do
  link = link_for params[:captures]
  link.update clicks: link.clicks + 1
  redirect link.url
end

put link do
  link = authorized_link_for params[:captures]
  updates = {}
  updates[:clicks] = 0 if params[:reset] = "1"
  updates[:url] = params[:url] if params[:url]
  link.update(updates);
  json link.errors.to_a
end

delete link do
  link = authorized_link_for params[:captures]
  json link.destroy ? [] : ["Unable to delete link #{link.name}."]
end
