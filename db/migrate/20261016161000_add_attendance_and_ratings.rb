class AddAttendanceAndRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances, id: :uuid do |t|
      t.uuid :run_id, null: false
      t.uuid :runner_id, null: false
      t.timestamps
    end
    add_index :attendances, [ :run_id, :runner_id ], unique: true
    create_table :participant_ratings, id: :uuid do |t|
      t.uuid :run_id, null: false
      t.uuid :rater_id, null: false
      t.uuid :ratee_id, null: false
      t.integer :punctuality, null: false
      t.integer :pace_accuracy, null: false
      t.integer :friendliness, null: false
      t.timestamps
    end
    add_index :participant_ratings, [ :run_id, :rater_id, :ratee_id ], unique: true, name: "unique_participant_rating"
    %w[punctuality pace_accuracy friendliness].each do |column|
      add_check_constraint :participant_ratings, "#{column} BETWEEN 1 AND 5", name: "valid_#{column}"
    end
  end
end
