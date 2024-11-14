# frozen_string_literal: true

module AuthorizationHelper
  def authorize(record, query = nil)
    query ||= "#{params[:action]}?"
    policy_class = record.is_a?(Class) ? record : record.class
    policy = "#{policy_class}Policy".constantize.new(current_user, record)

    unless policy.public_send(query)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def custom_authorize(record, query = nil)
    query ||= "#{params[:action]}?"
    policy = "#{record}Policy".constantize.new(current_user, record)

    unless policy.public_send(query)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end
