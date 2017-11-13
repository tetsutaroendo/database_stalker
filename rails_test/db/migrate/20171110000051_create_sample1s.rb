class CreateSample1s < ActiveRecord::Migration
  def change
    create_table :sample1s do |t|

      t.timestamps null: false
    end
  end
end
