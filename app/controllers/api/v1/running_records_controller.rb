module Api
  module V1
    class RunningRecordsController < AuthenticatedController
      before_action :set_running_record, only: %i[show update destroy]

      def index
        records = RunningRecord.where(runner_id: @runner_id).order(occurred_at: :desc)
        records = records.where(runner_id: params[:runner_id]) if params[:runner_id].present?

        render json: records
      end

      def show
        render json: @running_record
      end

      def create
        return unless eligible_run(running_record_params[:run_id])
        running_record = RunningRecord.new(running_record_params.merge(runner_id: @runner_id))

        if running_record.save
          render json: running_record, status: :created,
                 location: api_v1_running_record_url(running_record)
        else
          render_validation_errors(running_record)
        end
      end

      def update
        attributes = running_record_params.except(:run_id)
        if @running_record.update(attributes)
          render json: @running_record
        else
          render_validation_errors(@running_record)
        end
      end

      def destroy
        @running_record.destroy!
        head :no_content
      end

      private

      def set_running_record
        @running_record = RunningRecord.where(runner_id: @runner_id).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          error: {
            code: "running_record_not_found",
            message: "Running record was not found"
          }
        }, status: :not_found
      end

      def running_record_params
        params.expect(running_record: %i[
          run_id distance_meters duration_seconds occurred_at notes
        ])
      end

      def render_validation_errors(record)
        render json: {
          error: {
            code: "validation_failed",
            message: "Running record is invalid",
            details: record.errors.to_hash
          }
        }, status: :unprocessable_content
      end
    end
  end
end
