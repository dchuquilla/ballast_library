# frozen_string_literal: true

class LibrarianDashboardPolicy < BasePolicy
  def index?
    librarian?
  end
end
