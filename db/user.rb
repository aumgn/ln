require 'securerandom'

class User

  include DataMapper::Resource

  property :id,                Serial
  property :email,             String,
      required: true, unique: true, format: :email_address,
      messages: {
          presence:  "Password missing.",
          is_unique: "This email is already in use.",
          format:    "Invalid email."
       }
  property :password,          BCryptHash, required: true
  property :created_at,        DateTime
  property :admin,             Boolean, default: false
  property :auth_token,        String, unique: true, length: 100

  has n, :shortened_links

  before :save,   :create_auth_token

  def self.authenticate(email, password)
    user = first email: email
    if !user.nil? && user.password == password
      return user
    else
      return nil
    end
  end

  def create_auth_token
    begin
      new_auth_token = SecureRandom.base64(75)
    end while (User.first(auth_token: new_auth_token) != nil)
    self.auth_token = new_auth_token
  end
end
