class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.integer :user_id
      t.string  :name
      t.string  :normal_file_name
      t.text  :normal_file_contents
      t.text  :super_file_contents
      t.text  :distill_file_contents
      t.string  :arguments_file_name
      t.text  :arguments_file_contents
      t.integer :number_of_levels
      t.integer :number_of_runs      

      t.timestamps
    end
  end
end
