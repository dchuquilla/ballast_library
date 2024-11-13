require "rails_helper"

RSpec.describe BookSearchService, type: :service do
  describe "#call" do
    before(:all) do
      @isbn1 = SecureRandom.uuid
      @isbn2 = SecureRandom.uuid
      @book1 = create(:book, title: "Ruby on Rails", author: "David Heinemeier Hansson", isbn: @isbn1)
      @book2 = create(:book, title: "React for Beginners", author: "Dan Abramov", isbn: @isbn2)
    end

    let!(:book1) { @book1 }
    let!(:book2) { @book2 }

    it "returns books matching the query in title" do
      service = BookSearchService.new("Rails")
      result = service.call
      expect(result).to include(book1)
      expect(result).not_to include(book2)
    end

    it "returns books matching the query in author" do
      service = BookSearchService.new("Dan")
      result = service.call
      expect(result).to include(book2)
      expect(result).not_to include(book1)
    end

    it "returns books matching the query in isbn" do
      service = BookSearchService.new(@isbn1)
      result = service.call
      expect(result).to include(book1)
      expect(result).not_to include(book2)
    end

    it "returns an empty result when no books match the query" do
      service = BookSearchService.new("Nonexistent Book")
      result = service.call
      expect(result).to be_empty
    end
  end
end
