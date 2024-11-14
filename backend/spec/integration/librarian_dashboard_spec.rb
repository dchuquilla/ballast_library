# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"

RSpec.describe "v1/librarian/dashboard", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user, :librarian) }
  let(:members) { create_list(:user, 2) }
  let(:overdue_member) { create(:user) }
  let(:authorization) { get_token_bearer(user) }
  let(:books) { create_list(:book, 10) }
  let(:copies) { books.map { |book| create(:book_copy, book: book) } }
  let(:borrowings) { (1..3).map { |n| BorrowBookService.new(members.sample, { book_copy_id: copies[n].id }).call } }
  let(:borrowings_due_today) { (4..6).map { |n| create(:borrowing, user_id: members.sample.id, book_copy: copies[n], borrowed_at: Date.today - 2.weeks, due_date: Date.today) } }
  let(:borrowings_overdue) { (7..9).map { |n| create(:borrowing, user_id: overdue_member.id, book_copy: copies[n], borrowed_at: Date.today - 3.weeks, due_date: Date.today - 1.week) } }

  path "/v1/librarian/dashboard" do
    get "Retrieves the librarian dashboard" do
      tags "Librarian Dashboard"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      response "200", "dashboard retrieved" do
        schema type: :object,
               properties: {
                 total_books: { type: :integer },
                 total_borrowed_books: { type: :integer },
                 books_due_today: { type: :integer },
                 total_overdues: { type: :integer },
                 members_with_overdue_books: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       name: { type: :string },
                       email: { type: :string },
                     },
                     required: %w[name email],
                   },
                   nullable: true,
                 },
               },
               required: %w[total_books total_borrowed_books books_due_today total_overdues members_with_overdue_books]

        before do |example|
          overdue_member
          borrowings
          borrowings_due_today
          borrowings_overdue
          submit_request(example.metadata)
        end

        it "returns the correct SON representation" do
          expected_json = {
            total_books: 10,
            total_borrowed_books: 3,
            books_due_today: 3,
            total_overdues: 3,
            members_with_overdue_books: [
              { name: overdue_member.name, email: overdue_member.email },
            ],
          }.to_json

          expect(JSON.parse(response.body)).to eq(JSON.parse(expected_json))
        end
      end
    end
  end
end
