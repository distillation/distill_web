class CreateRunPoints < ActiveRecord::Migration
  def change
    create_table :run_points do |t|
      t.integer :run_id
      t.integer :user_id
      t.integer :program_id
      t.integer :run_type_id
      t.integer :run_time
      t.integer :mem_size

      t.timestamps
    end
  end
end
