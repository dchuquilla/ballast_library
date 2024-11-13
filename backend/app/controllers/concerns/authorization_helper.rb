# frozen_string_literal: true

module AuthorizationHelper
  def authorize(record, query = nil)
    query ||= "#{params}?"
    policy = "#{record.first.class.name}Policy".constantize.new(current_user, record.first.class)

    unless policy.public_send(query)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end
