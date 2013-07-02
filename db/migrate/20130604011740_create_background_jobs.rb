class CreateBackgroundJobs < ActiveRecord::Migration
  def change
    create_table :background_jobs do |t|
      t.integer :user_id, limit: 11
      t.string :filename, limit: 512
      t.string :type_view, limit: 255
      t.column :status, "char(1)", default: "0"
      t.string :filepath, limit: 512
      t.string :job_id, limit: 255

      t.timestamps
    end
  end
end
