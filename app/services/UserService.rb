=begin
  Defines a service class for performing operations relating to the User entity.

  This class also handles authentication, which would not be the case in a real world scenario. See
  readme.md for a more extensive discussion of this topic.
=end

require "securerandom"
require "bcrypt"
require_relative "../models/User"

class UserService
  # registers a user and returns an access token for them.
  #
  def register(username:, password:, name:)
    password_hash = BCrypt::Password.create(password)

    # we return the access token to the user on registration, so that they can immediately 
    # begin using it, without needing to re-login.
    #
    # expiry is hard-coded to be an hour from now in utc time. there is currently no way to
    # refresh the token.
    #
    access_token = SecureRandom.uuid
    access_token_hash = BCrypt::Password.create(access_token)
    access_token_expiry = Time.now.utc + 60 * 60

    user = User.create(
      username: username,
      password_hash: password_hash,
      name: name,
      access_token_hash: access_token_hash,
      access_token_expiry: access_token_expiry
    )

    user.access_token = access_token

    return user
  end

  # attempts to log a user in and returns an access token if successful.
  #
  def login(username:, password:)
    user = User.find_by! username: username

    if !BCrypt::Password.new(user.password_hash).is_password?(password) then
      raise "Password does not match."
    end

    access_token = SecureRandom.uuid
    access_token_hash = BCrypt::Password.create(access_token)
    access_token_expiry = Time.now.utc + 60 * 60

    user.access_token_hash = access_token_hash
    user.access_token_expiry = access_token_expiry
    user.save

    user.access_token = access_token

    return user
  end

  # determines whether or not an access token is valid for a specified user.
  #
  def is_auth_valid?(user_id, access_token)
    user = User.find user_id

    return BCrypt::Password.new(user.access_token_hash).is_password?(access_token) &&
      user.access_token_expiry > Time.now.utc
  end

  # returns the user with the specified user_id. probably not strictly necessary for this method to
  # exist, but keeping business logic out of controllers.
  #
  def get(user_id)
    User.find user_id
  end

  # adds one to the user's current integer value and returns the updated user entity.
  #
  def increment_integer(user_id)
    user = User.find user_id
    user.integer_value += 1
    user.save

    user
  end

  # sets the user's integer to a specific value
  #
  def reset_integer(user_id, value)
    # non-negative values enforced by database for now
    #
    user = User.find user_id
    user.integer_value = value
    user.save

    user
  end
end