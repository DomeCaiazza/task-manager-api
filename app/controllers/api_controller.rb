class ApiController < ApplicationController
    skip_before_action :verify_authenticity_token

    if !Rails.env.development?
      rescue_from StandardError, with: :handle_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    end

    private

    def handle_error(exception)
      render json: {
        error: {
          message: exception.message,
          type: exception.class.name
        }
      }, status: :internal_server_error
    end

    def handle_not_found(exception)
      render json: {
        error: {
          message: "Resource not found",
          type: "NotFound"
        }
      }, status: :not_found
    end

    def handle_parameter_missing(exception)
      render json: {
        error: {
          message: exception.message,
          type: "ParameterMissing"
        }
      }, status: :bad_request
    end
end
