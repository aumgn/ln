class ShortenedLink

  include DataMapper::Resource

  property :id,               Serial
  property :name,             String, required: true, unique: true, length: 16
  property :url,              String, length: 2_000, required: true, format: :url
  property :clicks,           Integer, default: 0
  property :created_at,       DateTime
  property :updated_at,       DateTime
  belongs_to :user

  validates_format_of :name, with: /^[0-9a-zA-Z]*$/,
      message: "The name can only contain alphanumeric characters."
end
