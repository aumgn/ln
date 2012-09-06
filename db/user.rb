class User

  include DataMapper::Resource

  property :id,                Serial
  property :name,              String,     length: 24, required: true
  property :password,          BCryptHash
  property :created_at,        DateTime 
end
