# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"

RSpec.describe "Book Copies API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user) }
  let(:authorization) { get_token_bearer(user) }
  let(:all_books) { FactoryBot.create_list(:book, 2) }
  let(:first_book_copies) { FactoryBot.create_list(:book_copy, 3, book: all_books.first) }
  let(:last_book_copies) { FactoryBot.create_list(:book_copy, 2, book: all_books.last) }

  path "/v1/member/books/{id}/book_copies" do
    get "Member List all book copies" do
      tags "Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"

      response "200", "book copies listed" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   book_id: { type: :integer },
                   copy_code: { type: :string },
                   status: { type: :string },
                   borrowed_at: { type: :string },
                   returned_at: { type: :string },
                 },
                 required: %w[id book_id status],
               }

        let(:id) { all_books.last.id }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "returns all book copies" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body.size).to eq(last_book_copies.size)
          expect(all_books.last.book_copies.pluck(:id)).to eq(body.map { |book_copy| book_copy["id"] })
          expect(all_books.last.book_copies.pluck(:copy_code)).to eq(body.map { |book_copy| book_copy["copy_code"] })
        end
      end
    end
  end

  path "/v1/member/books/{id}/book_copies/{book_copy_id}" do
    get "Member List book copy" do
      tags "Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"
      parameter name: :book_copy_id, in: :path, type: :string, required: true, description: "Book Copy ID"

      response "200", "book copy listed" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_id: { type: :integer },
                 copy_code: { type: :string },
                 status: { type: :string },
                 borrowed_at: { type: :string },
                 returned_at: { type: :string },
               }

        let(:id) { all_books.last.id }
        let(:book_copy_id) { last_book_copies.first.id }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "returns book copy" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body["id"]).to eq(last_book_copies.first.id)
          expect(body["copy_code"]).to eq(last_book_copies.first.copy_code)
        end
      end
    end
  end
end
