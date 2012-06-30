class CreateRunPoints < ActiveRecord::Migration
  def change
    create_table :run_points do |t|
      t.integer :run_id
      t.integer :user_id
      t.integer :program_id
      t.integer :run_type_id
      t.integer :level_id
      t.integer :run_time
      t.integer :mem_size

      t.timestamps
    end
    
    add_index :run_points, :user_id
    add_index :run_points, :program_id
    add_index :run_points, :run_id
    add_index :run_points, :run_type_id
  end
end
