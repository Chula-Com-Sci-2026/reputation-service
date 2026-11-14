module Api
  module V1
    class ReputationController < AuthenticatedController
      def confirm
        run = scheduling_request(params[:run_id], confirm: true)
        return unless run
        Attendance.find_or_create_by!(run_id: params[:run_id], runner_id: @runner_id)
        render json: { runId: params[:run_id], confirmed: true, status: run["status"] }
      end

      def rate
        run = eligible_run(params[:run_id])
        return unless run
        unless run.fetch("confirmedIds", []).include?(params[:rateeId]) && params[:rateeId] != @runner_id
          render json: { code: "ineligible", message: "Choose another confirmed participant" }, status: :forbidden
          return
        end
        rating = ParticipantRating.new(run_id: params[:run_id], rater_id: @runner_id, ratee_id: params[:rateeId],
          punctuality: params[:punctuality], pace_accuracy: params[:paceAccuracy], friendliness: params[:friendliness])
        if rating.save
          render json: rating, status: :created
        else
          render json: { code: "invalid_rating", message: rating.errors.full_messages.join(", ") }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotUnique
        render json: { code: "duplicate", message: "Participant already rated for this run" }, status: :conflict
      end

      def summary
        ratings = ParticipantRating.where(ratee_id: params[:runner_id])
        count = ratings.count
        average = count >= 3 ? (ratings.average(:punctuality).to_f + ratings.average(:pace_accuracy).to_f + ratings.average(:friendliness).to_f) / 3 : nil
        render json: { runnerId: params[:runner_id], count: count, rating: average&.round(2), hidden: count < 3 }
      end

      # Another runner's totals only. Their individual records (dates, runs, notes) stay private to
      # them through `history`.
      def running_summary
        records = RunningRecord.where(runner_id: params[:runner_id])
        render json: { runnerId: params[:runner_id], runs: records.count,
          totalDistanceMeters: records.sum(:distance_meters), totalDurationSeconds: records.sum(:duration_seconds) }
      end

      def history
        records = RunningRecord.where(runner_id: @runner_id).order(occurred_at: :desc)
        render json: { records: records, totalDistanceMeters: records.sum(:distance_meters), totalDurationSeconds: records.sum(:duration_seconds) }
      end
    end
  end
end
