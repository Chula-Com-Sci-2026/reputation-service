require "test_helper"

class RunningRecordTest < ActiveSupport::TestCase
  test "requires positive distance and duration" do
    record = RunningRecord.new(
      run_id: SecureRandom.uuid,
      runner_id: SecureRandom.uuid,
      distance_meters: 0,
      duration_seconds: -1,
      occurred_at: Time.current
    )

    assert_not record.valid?
    assert record.errors.of_kind?(:distance_meters, :greater_than)
    assert record.errors.of_kind?(:duration_seconds, :greater_than)
  end

  test "allows only one record per runner and run" do
    attributes = valid_attributes
    RunningRecord.create!(attributes)
    duplicate = RunningRecord.new(attributes)

    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:run_id, :taken)
  end

  private

  def valid_attributes
    {
      run_id: SecureRandom.uuid,
      runner_id: SecureRandom.uuid,
      distance_meters: 5_000,
      duration_seconds: 1_800,
      occurred_at: Time.current
    }
  end
end
