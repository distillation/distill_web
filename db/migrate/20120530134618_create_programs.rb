class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.integer :user_id
      t.string  :name
      t.string  :file_name
      t.string  :arguments_file_name
      t.integer :size
      t.integer :lines
      t.integer :number_of_levels
      t.integer :number_of_runs      

      t.timestamps
    end
  end
end
