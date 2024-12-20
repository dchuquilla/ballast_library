# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"
require "faker"

RSpec.describe "Books API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user) }
  let(:authorization) { get_token_bearer(user) }
  let(:all_books) { create_list(:book, 50) }

  path "/v1/member/books" do
    get "Member List all books" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      response(200, "books listed") do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   author: { type: :string },
                   genre: { type: :string },
                   isbn: { type: :string },
                   total_copies: { type: :integer },
                 },
                 required: %w[id title author genre isbn total_copies],
               }

        before do |example|
          all_books
          submit_request(example.metadata)
        end

        it "returns all books" do
          body = JSON.parse(response.body)
          target_book = all_books.last

          expect(response).to have_http_status(:ok)
          expect(target_book.title).to eq(body.find { |book| book["id"] == target_book.id }["title"])
          expect(body.size).to eq(Book.count)
        end
      end
    end
  end

  path "/v1/member/books/{id}" do
    get "Member see a single book with its copies" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :integer, required: true

      let(:book) { create(:book) }
      let(:book_copies) { create_list(:book_copy, 3, book: book) }

      response(200, "book found") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 author: { type: :string },
                 genre: { type: :string },
                 isbn: { type: :string },
                 total_copies: { type: :integer },
                 book_copies: {
                   type: :array,
                   nulllable: true,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       book_id: { type: :integer },
                       status: { type: :string },
                     },
                     required: %w[id book_id status],
                   },
                 },
               },
               required: %w[id title author genre isbn total_copies book_copies]

        let(:id) { book.id }

        before do |example|
          book_copies
          submit_request(example.metadata)
        end

        it "returns the book" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(book.title).to eq(body["title"])
          expect(book_copies.count).to eq(body["book_copies"].size)
        end
      end
    end
  end

  path "/v1/member/books/search" do
    get "Member Search books" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :query, in: :query, type: :string, required: true

      response(200, "books listed") do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   author: { type: :string },
                   genre: { type: :string },
                   isbn: { type: :string },
                   total_copies: { type: :integer },
                 },
                 required: %w[id title author genre isbn total_copies],
               }

        let(:query) { all_books.first.isbn }

        before do |example|
          all_books
          submit_request(example.metadata)
        end

        it "returns found books" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body.size).to eq(1)
          expect(all_books.first.isbn).to eq(body.first["isbn"])
        end
      end
    end
  end
end
