class CreateRunTypes < ActiveRecord::Migration
  def change
    create_table :run_types do |t|
      t.string :name
      t.string :description
      t.string :folder_name
      t.string :options
      t.string :transformation_name

      t.timestamps
    end
  end
end
