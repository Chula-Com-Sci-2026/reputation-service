class CreateRunningRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :running_records, id: :uuid do |t|
      t.uuid :run_id, null: false
      t.uuid :runner_id, null: false
      t.integer :distance_meters, null: false
      t.integer :duration_seconds, null: false
      t.datetime :occurred_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :running_records, %i[runner_id occurred_at]
    add_index :running_records, %i[run_id runner_id], unique: true
  end
end
