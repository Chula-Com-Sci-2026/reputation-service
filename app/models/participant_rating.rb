class ParticipantRating < ApplicationRecord
  validates :punctuality, :pace_accuracy, :friendliness, inclusion: { in: 1..5 }
  validates :run_id, uniqueness: { scope: [ :rater_id, :ratee_id ] }
  validate { errors.add(:ratee_id, "cannot rate yourself") if rater_id == ratee_id }
end
