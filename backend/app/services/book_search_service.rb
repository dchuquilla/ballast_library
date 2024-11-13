# frozen_string_literal: true

class BookSearchService
  def initialize(query)
    @query = query
  end

  def call
    Book.where("title ILIKE ? OR author ILIKE ? OR isbn ILIKE ?", "%#{@query}%", "%#{@query}%", "%#{@query}%")
  end
end
