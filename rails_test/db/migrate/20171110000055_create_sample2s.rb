class CreateSample2s < ActiveRecord::Migration
  def change
    create_table :sample2s do |t|

      t.timestamps null: false
    end
  end
end
