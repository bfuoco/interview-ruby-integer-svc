=begin
  Defines the user entity, which stores a user's authentication and integer information.

  The user's current access token is also stored in this table, for now. This has a number of
  limitations, as described in the README.md file.

  Attributes:
  - id  number
  - username  string[128]  email; uniqueness enforced by a unique index
  - password_hash  binary[60]  bcrypt hash of the user's password
  - name  string[128]
  - access_token_hash  binary[60]  bcrypt hash of the user's current access token
  - access_token_expiry  datetime  the utc timestamp when the user's 
  - integer  integer  the user's current, non-negative integer; enforced by check constraint
=end

require_relative 'BaseModel'

class User < BaseModel
  # these attributes are not serialized when returning the model to the user.
  #  
  def except_attributes
    ["id", "password_hash", "access_token_hash", "access_token_expiry"].freeze
  end

  # only used on user registration and login - the access token is set here by the user service so
  # that it can be returned to the user. it is not serialized.
  #
  attr_accessor :access_token
end