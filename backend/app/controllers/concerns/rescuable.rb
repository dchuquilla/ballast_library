# frozen_string_literal: true

module Rescuable
  def self.included(base)
    base.class_eval do
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    end
  end

  private

  def render_not_found_response(exception)
    render json: { errors: ["not found"], code: :not_found }, status: :not_found
  end
end
