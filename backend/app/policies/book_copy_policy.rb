# frozen_string_literal: true

class BookCopyPolicy < BasePolicy
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
    librarian? || member? # Both roles can view book copies
  end

  def index?
    librarian? || member? # Both roles can view book copies
  end
end
