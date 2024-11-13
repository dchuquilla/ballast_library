# frozen_string_literal: true

class BorrowingPolicy < BasePolicy
  def update?
    librarian?
  end

  def destroy?
    librarian?
  end

  def borrow?
    member?
  end

  def return?
    librarian?
  end

  def show?
    librarian? || member?
  end

  def index?
    librarian? || member?
  end
end
