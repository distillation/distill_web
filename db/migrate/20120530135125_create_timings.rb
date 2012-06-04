class CreateTimings < ActiveRecord::Migration
  def change
    create_table :timings do |t|
      t.integer :user_id
      t.integer :program_id
      t.string  :arguments
      t.decimal :normal_compile
      t.decimal :normal_O2_compile
      t.decimal :super_compile
      t.decimal :super_O2_compile
      t.decimal :distill_compile
      t.decimal :distill_O2_compile
      t.decimal :normal_time
      t.decimal :normal_O2_time
      t.decimal :super_time
      t.decimal :super_O2_time
      t.decimal :distill_time
      t.decimal :distill_02_time
      t.integer :normal_mem
      t.integer :normal_O2_mem
      t.integer :super_mem
      t.integer :super_O2_mem
      t.integer :distill_mem
      t.integer :distill_O2_mem

      t.timestamps
    end
  end
end
