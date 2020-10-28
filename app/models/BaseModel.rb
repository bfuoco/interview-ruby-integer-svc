=begin
  Defines a base model class.

  This is not meant to be instantiated, but to provide some basic functionality common to all
  models.
=end
class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  # returns a list of attributes that should not be serialized by the to_json_api_entity method. 
  # this method is meant to be overridden by derived classes so that they can specify which
  # attributes should not be overridden.
  #
  def except_attributes
    [].freeze
  end

  # serializes the entity in the json:api format.
  #
  # for example, User(id=42, username=bubba@fuoco.com, name="Bubba Fuoco") would be serialized as:
  #
  # {
  #   "id": 42,
  #   "type": "users",
  #   "attributes": {
  #     "username": "bubba@fuoco.com",
  #     "name": "Bubba Fuoco"
  #   }
  # }
  #
  def to_json_api_entity
    {
      :type => self.class.table_name,
      :id => self.id,
      :attributes => self.attributes.except(*self.except_attributes)
    }
  end
end