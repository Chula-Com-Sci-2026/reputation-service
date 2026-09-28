class RunningRecord < ApplicationRecord
  validates :run_id, :runner_id, :occurred_at, presence: true
  validates :distance_meters, :duration_seconds,
            numericality: { only_integer: true, greater_than: 0 }
  validates :run_id, uniqueness: { scope: :runner_id }
end
