# frozen_string_literal: true

class BookPolicy < BasePolicy
  def create?
    librarian?
  end

  def update?
    librarian?
  end

  def destroy?
    librarian?
  end

  def show?
    librarian? || member? # Both roles can view books
  end
end
