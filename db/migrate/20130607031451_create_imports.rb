class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :csv_file_name
      t.string :csv_content_type
      t.string :csv_file_size

      t.timestamps
    end
  end
end
