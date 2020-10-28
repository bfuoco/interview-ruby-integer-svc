=begin
  Defines a file to register the routes specific to handling users.

  This exists to separate out the routing logic from the core app class. the app class can focus
  solely on setup, error handling, and the like, while this controller class can focus specifically
  on defining api routing.
=end
class UserController
  def register(app, r)
    r.on "register" do
      app.enforce_json_api_content_type_policy

      # POST /register
      #
      # sample request body:
      # {
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bernard@outlook.com",
      #       "password": "bernard_is_a_robot",
      #       "name": "Bernard"
      #     }
      #   }
      # }
      #
      # sample response body:
      # {
      #   "id": 600,
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bernard@outlook.com",
      #       "name": "Bernard",
      #       "integer_value": 0
      #     }
      #   }
      # }
      #
      r.post do
        request_body = JSON.parse(r.body.read)
        data = request_body["data"]["attributes"]

        user = app.users.register(
          username: data["username"].to_str,
          password: data["password"].to_str,
          name: data["name"].to_str
        )

        result = {
          :data => user.to_json_api_entity
        }.to_json
        
        r.response.headers["X-Api-Access-Token"] = user.access_token
        r.response.status = 201
        "#{result}"
      end
    end

    r.on "login" do
      app.enforce_json_api_content_type_policy
    
      # POST /login
      #
      # sample request body:
      # {
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bernard@outlook.com",
      #       "password": "bernard_is_a_robot",
      #     }
      #   }
      # }
      #
      # sample response body:
      # {
      #   "id": 600,
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bernard@outlook.com",
      #       "name": "Bernard",
      #       "integer_value": 50
      #     }
      #   }
      # }
      #      
      r.post do
        request_body = JSON.parse(r.body.read)
        data = request_body["data"]["attributes"]

        user = app.users.login(
          username: data["username"].to_str,
          password: data["password"].to_str
        )

        result = {
          :data => user.to_json_api_entity
        }.to_json
        
        r.response.headers["X-Api-Access-Token"] = user.access_token
        r.response.status = 200
        "#{result}"
      end
    end

    r.on "current", Integer do |user_id|
      # GET /current/{user_id}
      #
      # sample response body:
      # {
      #   "id": 5, 
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bfuoco@gmail.com",
      #       "name": "Bubba Fuoco",
      #       "integer_value": 45
      #     }
      #   }
      # }
      #
      r.get do
        app.enforce_json_api_content_type_policy
        app.require_authentication user_id

        user = app.users.get user_id

        result = {
          :data => user.to_json_api_entity
        }.to_json

        r.response.status = 200
        "#{result}"
      end

      # PUT /current/{user_id}
      #
      # resets the user's integer to a specific number.
      #
      # sample request body, resetting user's integer to 450:
      # {
      #   "id": 5, 
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "integer_value": 450
      #     }
      #   }
      # }
      #
      # sample response body
      # {
      #   "id": 5, 
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bfuoco@gmail.com",
      #       "name": "Bubba Fuoco",
      #       "integer_value": 450
      #     }
      #   }
      # }
      #
      r.put do
        app.enforce_json_api_content_type_policy
        app.require_authentication user_id

        request_body = JSON.parse(r.body.read)
        data = request_body["data"]["attributes"]

        user = app.users.reset_integer user_id, data["integer_value"].to_i

        result = {
          :data => user.to_json_api_entity
        }.to_json

        r.response.status = 200
        "#{result}"
      end
    end

    r.on "next", Integer do |user_id|
      # POST /next/{user_id}
      #
      # increments the user's integer by 1
      #
      # no request body expected
      #
      # sample response body
      # {
      #   "id": 5, 
      #   "type": "users",
      #   "data": {
      #     "attributes": {
      #       "username": "bfuoco@gmail.com",
      #       "name": "Bubba Fuoco",
      #       "integer_value": 451
      #     }
      #   }
      # }
      #      
      r.post do
        app.require_authentication user_id

        user = app.users.increment_integer user_id

        result = {
          :data => user.to_json_api_entity
        }.to_json

        r.response.status = 200
        "#{result}"
      end
    end    
  end
end