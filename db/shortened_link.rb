class ShortenedLink

  FORBIDDEN = [
               "admin",
               "login",
               "logout"
              ]

  include DataMapper::Resource

  property :id,               Serial
  property :name,             String, required: true, unique: true, length: 16
  property :url,              String, required: true, format: :url
  property :created_at,       DateTime
  property :updated_at,        DateTime
  belongs_to :user

  validates_format_of :name, with: /[0-9a-zA-Z]{1,16}/,
      message: "The name can only contain alphanumeric characters."

  validates_with_block :name do
    if FORBIDDEN.include? @name
      [false, "This is a reserved name."]
    else
      true
    end
  end
end
