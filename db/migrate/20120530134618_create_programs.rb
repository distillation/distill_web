class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.integer :user_id
      t.string :name
      t.string :file_name
      t.integer :size
      t.integer :lines

      t.timestamps
    end
  end
end
