class CreateRunTypes < ActiveRecord::Migration
  def change
    create_table :run_types do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
