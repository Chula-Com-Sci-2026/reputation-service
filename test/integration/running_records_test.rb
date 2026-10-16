require "test_helper"

class RunningRecordsTest < ActionDispatch::IntegrationTest
  setup do
    @runner_id = SecureRandom.uuid
    @headers = { "Authorization" => token_for(@runner_id) }
    @record = RunningRecord.create!(valid_attributes)
  end

  test "lists running records" do
    get api_v1_running_records_url, headers: @headers

    assert_response :success
    assert_equal @record.id, response.parsed_body.first.fetch("id")
  end

  test "shows a running record" do
    get api_v1_running_record_url(@record), headers: @headers

    assert_response :success
    assert_equal @record.id, response.parsed_body.fetch("id")
  end

  test "returns not found for an unknown record" do
    get api_v1_running_record_url(SecureRandom.uuid), headers: @headers

    assert_response :not_found
    assert_equal "running_record_not_found", response.parsed_body.dig("error", "code")
  end

  test "creates a running record" do
    assert_difference("RunningRecord.count", 1) do
      with_eligible_run do
      post api_v1_running_records_url, params: {
        running_record: valid_attributes.merge(run_id: SecureRandom.uuid)
      }, as: :json, headers: @headers
      end
    end

    assert_response :created
  end

  test "rejects an invalid running record" do
    with_eligible_run do
    post api_v1_running_records_url, params: {
      running_record: valid_attributes.merge(distance_meters: 0)
    }, as: :json, headers: @headers
    end
    assert_response :unprocessable_content
    assert_equal "validation_failed", response.parsed_body.dig("error", "code")
  end

  test "updates a running record" do
    patch api_v1_running_record_url(@record), params: {
      running_record: { notes: "Evening recovery run" }
    }, as: :json, headers: @headers

    assert_response :success
    assert_equal "Evening recovery run", @record.reload.notes
  end

  test "deletes a running record" do
    assert_difference("RunningRecord.count", -1) do
      delete api_v1_running_record_url(@record), headers: @headers
    end

    assert_response :no_content
  end

  test "requires authentication and hides another runners records" do
    get api_v1_running_records_url
    assert_response :unauthorized
    get api_v1_running_record_url(@record), headers: { "Authorization" => token_for(SecureRandom.uuid) }
    assert_response :not_found
  end

  private

  def with_eligible_run
    require "net/http"
    response = Net::HTTPOK.new("1.1", "200", "OK")
    runner = @runner_id
    response.define_singleton_method(:body) { { status: "completed", confirmedIds: [ runner ] }.to_json }
    original = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*args, **kwargs, &block| response }
    yield
  ensure
    Net::HTTP.define_singleton_method(:start, original) if original
  end

  def valid_attributes
    {
      run_id: SecureRandom.uuid,
      runner_id: @runner_id,
      distance_meters: 5_000,
      duration_seconds: 1_800,
      occurred_at: "2026-09-28T12:00:00Z",
      notes: "Steady pace"
    }
  end
end
