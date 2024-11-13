# frozen_string_literal: true

module Rescuable
  def self.included(base)
    base.class_eval do
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { errors: ["not found"], code: :not_found }, status: :not_found
      end
    end
  end
end
