require "test_helper"

class RunningRecordsTest < ActionDispatch::IntegrationTest
  setup do
    @record = RunningRecord.create!(valid_attributes)
  end

  test "lists running records" do
    get api_v1_running_records_url

    assert_response :success
    assert_equal @record.id, response.parsed_body.first.fetch("id")
  end

  test "shows a running record" do
    get api_v1_running_record_url(@record)

    assert_response :success
    assert_equal @record.id, response.parsed_body.fetch("id")
  end

  test "returns not found for an unknown record" do
    get api_v1_running_record_url(SecureRandom.uuid)

    assert_response :not_found
    assert_equal "running_record_not_found", response.parsed_body.dig("error", "code")
  end

  test "creates a running record" do
    assert_difference("RunningRecord.count", 1) do
      post api_v1_running_records_url, params: {
        running_record: valid_attributes.merge(run_id: SecureRandom.uuid)
      }, as: :json
    end

    assert_response :created
  end

  test "rejects an invalid running record" do
    post api_v1_running_records_url, params: {
      running_record: valid_attributes.merge(distance_meters: 0)
    }, as: :json

    assert_response :unprocessable_content
    assert_equal "validation_failed", response.parsed_body.dig("error", "code")
  end

  test "updates a running record" do
    patch api_v1_running_record_url(@record), params: {
      running_record: { notes: "Evening recovery run" }
    }, as: :json

    assert_response :success
    assert_equal "Evening recovery run", @record.reload.notes
  end

  test "deletes a running record" do
    assert_difference("RunningRecord.count", -1) do
      delete api_v1_running_record_url(@record)
    end

    assert_response :no_content
  end

  private

  def valid_attributes
    {
      run_id: SecureRandom.uuid,
      runner_id: SecureRandom.uuid,
      distance_meters: 5_000,
      duration_seconds: 1_800,
      occurred_at: "2026-09-28T12:00:00Z",
      notes: "Steady pace"
    }
  end
end
