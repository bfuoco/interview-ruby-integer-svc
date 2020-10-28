require "active_record"

class CreateUserEntity < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username, null: false, limit: 128
      t.binary :password_hash, null: false, limit: 60
      t.string :name, null: false, limit: 128
      t.binary :access_token_hash, null: false, limit: 60
      t.datetime :access_token_expiry, null: false
      t.integer :integer_value, null: false, default: 0
      t.timestamps

      t.index :username, unique: true
      t.index :access_token_hash
    end

    execute \
      "ALTER TABLE users " \
        "ADD CONSTRAINT integer_value_cannot_be_negative " \
        "CHECK (integer_value >= 0)"
  end
end