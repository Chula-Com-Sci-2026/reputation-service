module Api
  module V1
    class AuthenticatedController < ApplicationController
      before_action :authenticate_runner

      private

      def authenticate_runner
        @runner_id = AccessToken.subject(request.headers["Authorization"])
      rescue AccessToken::Invalid
        render json: { code: "unauthorized", message: "Valid access token required" }, status: :unauthorized
      end

      def scheduling_request(run_id, confirm: false)
        require "net/http"
        uri = URI(ENV.fetch("SCHEDULING_URL") + "/api/v1/runs/#{run_id}" + (confirm ? "/attendance-confirmation" : ""))
        outgoing = confirm ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
        outgoing["Authorization"] = request.headers["Authorization"]
        response = Net::HTTP.start(uri.hostname, uri.port, open_timeout: 3, read_timeout: 5) { |http| http.request(outgoing) }
        unless response.is_a?(Net::HTTPSuccess)
          render json: { code: "run_ineligible", message: "Run participation or state does not permit this operation" }, status: response.code.to_i
          return nil
        end
        JSON.parse(response.body)
      rescue IOError, SystemCallError, Timeout::Error
        render json: { code: "unavailable", message: "Scheduling service unavailable" }, status: :service_unavailable
        nil
      end

      def eligible_run(run_id)
        run = scheduling_request(run_id)
        return nil unless run
        unless run["status"] == "completed" && run.fetch("confirmedIds", []).include?(@runner_id)
          render json: { code: "ineligible", message: "Confirmed attendance in a completed run is required" }, status: :forbidden
          return nil
        end
        run
      end
    end
  end
end
