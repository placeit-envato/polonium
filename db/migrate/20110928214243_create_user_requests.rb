class CreateUserRequests < ActiveRecord::Migration
  def self.up
    create_table :user_requests do |t|
      t.integer :user_id
      t.timestamp :date
      t.integer :requests_done

      t.timestamps
    end
  end

  def self.down
    drop_table :user_requests
  end
end
