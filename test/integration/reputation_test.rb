require "test_helper"
require "net/http"

class ReputationTest < ActionDispatch::IntegrationTest
  setup do
    @runner = SecureRandom.uuid
    @buddy = SecureRandom.uuid
    @run = SecureRandom.uuid
    @headers = { "Authorization" => token_for(@runner) }
  end

  test "confirms attendance idempotently after scheduling accepts it" do
    scheduling({ status: "attendance_open" }) do
      2.times do
        post "/api/v1/runs/#{@run}/attendance", headers: @headers
        assert_response :success
      end
    end
    assert_equal 1, Attendance.where(run_id: @run, runner_id: @runner).count
  end

  test "rates a confirmed buddy once and validates score range" do
    scheduling({ status: "completed", confirmedIds: [ @runner, @buddy ] }) do
      post "/api/v1/runs/#{@run}/ratings", params: rating, as: :json, headers: @headers
      assert_response :created
      post "/api/v1/runs/#{@run}/ratings", params: rating, as: :json, headers: @headers
      assert_response :unprocessable_content
      post "/api/v1/runs/#{SecureRandom.uuid}/ratings", params: rating.merge(punctuality: 0), as: :json, headers: @headers
      assert_response :unprocessable_content
    end
  end

  test "rejects self ratings and ratings before completion" do
    scheduling({ status: "completed", confirmedIds: [ @runner, @buddy ] }) do
      post "/api/v1/runs/#{@run}/ratings", params: rating.merge(rateeId: @runner), as: :json, headers: @headers
      assert_response :forbidden
    end
    scheduling({ status: "attendance_open", confirmedIds: [ @runner ] }) do
      post "/api/v1/runs/#{@run}/ratings", params: rating, as: :json, headers: @headers
      assert_response :forbidden
    end
  end

  test "hides aggregate until three ratings exist" do
    2.times do
      ParticipantRating.create!(run_id: SecureRandom.uuid, rater_id: SecureRandom.uuid, ratee_id: @buddy,
        punctuality: 4, pace_accuracy: 5, friendliness: 3)
    end
    get "/api/v1/runners/#{@buddy}/rating-summary", headers: @headers
    assert response.parsed_body["hidden"]
    assert_nil response.parsed_body["rating"]
    ParticipantRating.create!(run_id: SecureRandom.uuid, rater_id: @runner, ratee_id: @buddy,
      punctuality: 4, pace_accuracy: 5, friendliness: 3)
    get "/api/v1/runners/#{@buddy}/rating-summary", headers: @headers
    assert_equal 4, response.parsed_body["rating"]
  end

  private

  def rating
    { rateeId: @buddy, punctuality: 5, paceAccuracy: 4, friendliness: 5 }
  end

  def scheduling(body)
    fake = Net::HTTPOK.new("1.1", "200", "OK")
    fake.define_singleton_method(:body) { body.to_json }
    original = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*args, **kwargs, &block| fake }
    yield
  ensure
    Net::HTTP.define_singleton_method(:start, original) if original
  end
end
