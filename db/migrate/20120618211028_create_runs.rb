class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.integer :user_id
      t.integer :program_id
      t.decimal :ghc_compile_time
      t.decimal :super_compile_time
      t.decimal :distill_compile_time
      t.integer :ghc_size
      t.integer :super_size
      t.integer :distill_size
      t.integer :level_number

      t.timestamps
    end
  end
end
