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
    redirect(scheme + request.host_with_port + "/~login") if current_user.nil?
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

get '/~login' do
  secure_only
  slim :login
end

post '/~login' do
  secure_only
  user = User.authenticate(params[:email], params[:password])
  if user.nil?
    @login_error = "Invalid email or password."
    slim :login
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

get '/~register' do
  secure_only
  slim :register
end

post '/~register' do
  secure_only
  new_user = User.create email: params[:email], password: ""
  if new_user.errors.size > 0
    @errors = new_user.errors.to_a.map { |e| e.first }
    slim :register
  else
    @password_reset = PasswordReset.create(user: new_user)
    slim :registered
  end
end

get /~(.{100})/ do |token|
  reset = PasswordReset.for_token token
  raise Sinatra::NotFound if reset.nil?
  slim :reset
end

post /~(.{100})/ do |token|
  reset = PasswordReset.for_token token
  raise Sinatra::NotFound if reset.nil?
  password = params[:password]
  password_confirmation = params[:password_confirmation]
  if password.nil? || password.empty?
    @errors = ["Password can't be blank"]
  elsif password == password_confirmation
    if reset.user.update password: password
      reset.destroy
      redirect '/~login'
    end
    @errors = reset.user.errors.map do |error|
      error.first
    end
  else
    @errors = ["Passwords do not match"]
  end
  slim :reset
end

get '/~logout' do
  logged_only
  cookies[:auth_token] = nil
  redirect '/~login'
end

link = %r{^/([0-9a-zA-Z]+)$}

get link do |name|
  link = link_for name
  link.update clicks: link.clicks + 1
  redirect link.url
end

put link do |name|
  link = authorized_link_for name
  updates = {}
  updates[:clicks] = 0 if params[:reset] == "1"
  updates[:url] = params[:url] if params[:url]
  link.update(updates)
  json link.errors.to_a
end

delete link do |name|
  link = authorized_link_for name
  json link.destroy ? [] : ["Unable to delete link #{link.name}."]
end
