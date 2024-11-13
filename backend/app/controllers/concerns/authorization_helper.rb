# frozen_string_literal: true

module AuthorizationHelper
  def authorize(record, query = nil)
    query ||= "#{action_name}?"
    policy = "#{record.class}Policy".constantize.new(current_user, record)

    unless policy.public_send(query)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end
