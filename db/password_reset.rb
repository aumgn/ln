require 'securerandom'

class PasswordReset

  include DataMapper::Resource

  property :token,             String,
      unique: true, length: 100
  property :expires,           Time

  belongs_to :user, key: true

  before :create,      :init_expires
  before :save,        :create_token

  def self.for_token(token)
    reset = first(token: token)
    return nil if reset.nil?
    if reset.expires < Time.now
      destroy
      return nil
    end
    return reset
  end

  def init_expires
    self.expires = Time.now + (2 * 60 * 60)
  end

  def create_token
    begin
      new_token = SecureRandom.urlsafe_base64 75
    end while PasswordReset.first(token: new_token) != nil
    self.token = new_token
  end
end
