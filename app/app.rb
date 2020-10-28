require "active_record"
require "roda"

require_relative "controllers/UserController"
require_relative "services/UserService"

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  host: ENV["DB_HOST"],
  username: ENV["DB_USERNAME"],
  password: ENV["DB_PASSWORD"],
  database: ENV["DB_NAME"]
)

class App < Roda
  attr_reader :users

  def initialize(env)
    super env

    # for testing, the initialization of these could be bumped up a level and injected.
    #
    @user_routes = UserController.new
    @users = UserService.new
  end

  # enforces the json:api requirement that all requests have the correct content type header and
  # that no content-type headers specify any media type parameters.
  #
  # for example, this is legal:
  #   Content-Type: application/vnd.api+json
  #
  # this is not:
  #   Content-Type: application/vnd.api+json; version=1
  #
  # also sets the response content type, since all requests with this content type must reply with
  # the same json:api content type.
  #
  def enforce_json_api_content_type_policy()
    r = request
    content_type = r.env["CONTENT_TYPE"]

    if !content_type.starts_with?("application/vnd.api+json") then
      r.response.status = 415
      raise "Expected HTTP request Content-Type header to be \"application/vnd.api+json\"."
    elsif content_type != "application/vnd.api+json" then
      r.response.status = 415
      raise "HTTP request Content-Type header cannot have any media parameters."
    end

    response.headers["Content-Type"] = "application/vnd.api+json"
  end

  # enforces the json:api requirement that if one or more Accept headers are present with the
  # json:api content type, that at least one of these headers must not specify any media parameters.
  #
  # as an example, this is legal:
  #   Accept: application/vnd.api+json; version=1
  #   Accept: application/vnd.api+json
  #
  # this is not:
  #   Accept: application/vnd.api+json; version=1
  #
  # neither is this:
  #   Accept: application/vnd.api+json; version=1
  #   Accept: application/vnd.api+json; version=2
  #
  def enforce_json_api_accept_policy()
    r = request

    accept_types = r.env["HTTP_ACCEPT"].split(",")
    if accept_types.any? { |type| type.strip.starts_with?("application/vnd.api+json") } &&
        accept_types.none? { |type| type.strip == "application/vnd.api+json" }
    then
      r.response.status = 406
      raise "If an HTTP request specifies one or more Accept headers with a content type of " \
        "\"application/vnd.api+json\", at least one Accept header must not have any media type " \
        "parameters."
    end
  end

  # enforce authentication for the specified user.
  #
  # this compares the bearer token in the Authorization header to the a hash of the user's bearer
  # token, which is stored in the database. an error is raised if this does not match.
  #
  # it would be better if this was implemented less imperatively. a brief discussion of this is
  # covered in the readme file.
  #
  def require_authentication(user_id) 
    r = request

    if !r.env.key?("HTTP_AUTHORIZATION") then
      r.response.status = 401
      raise "Unauthorized; no bearer token was present in request headers."
    end

    authorization = r.env["HTTP_AUTHORIZATION"].strip()

    pattern = /^Bearer\s*:\s*([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})$/
    match = pattern.match authorization

    if match == nil then
      r.response.status = 401
      raise "Unauthorized; authorization header is malformed."
    end

    if !@users.is_auth_valid? user_id, match[1] then
      r.response.status = 401
      raise "Unauthorized; invalid access token."
    end
  end

  # this section registers all routing.
  #
  # the routes themselves are in controller files. as of now, there is only one controller, but
  # other controllers could potentially be registered at the end of this block.
  #
  plugin :all_verbs

  route do |r|
    # allows cross origin requests.
    #
    # there is probably a plugin for this, but i didn't understand the plugin system when I wrote 
    # this, so live and learn.
    #
    if env.include? "HTTP_ORIGIN" then
      response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, OPTIONS"
      response.headers["Access-Control-Allow-Origin"] = env["HTTP_ORIGIN"] 
      response.headers["Access-Control-Expose-Headers"] = "X-Api-Access-Token"
      response.headers["Vary"] = "Origin"
    end

    r.options do
      response.status = 200
      response.headers["Access-Control-Allow-Headers"] = "Authorization,Content-Type"

      ""
    end

    r.get "ok" do
      response.status = 200
      ""
    end

    enforce_json_api_accept_policy

    @user_routes.register self, r
  rescue => error
    if response.status == nil then response.status = 500 end

    # https://jsonapi.org/format/#errors-processing
    #
    # backtrace should be omitted for production. would also be nice to get the error source
    # in here so we could show the error under the specific form input field that it belongs to.
    {
      :status => response.status,
      :errors => [error],
      :meta => {
        :backtrace => error.backtrace
      }
    }.to_json
  end
end