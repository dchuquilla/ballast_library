# frozen_string_literal: true

class BasePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def librarian?
    user&.role == APP_ROLES[:librarian]
  end

  def member?
    user&.role == APP_ROLES[:member]
  end
end
