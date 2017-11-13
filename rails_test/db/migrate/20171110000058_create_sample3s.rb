class CreateSample3s < ActiveRecord::Migration
  def change
    create_table :sample3s do |t|

      t.timestamps null: false
    end
  end
end
