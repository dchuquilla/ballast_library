# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"
require "devise/jwt/test_helpers"

RSpec.describe "Librarian book Copies API", type: :request do
  include Helpers::Authentication

  let(:user) { create(:user, :librarian) }
  let(:authorization) { get_token_bearer(user) }
  let(:all_books) { FactoryBot.create_list(:book, 2) }
  let(:first_book_copies) { FactoryBot.create_list(:book_copy, 3, book: all_books.first) }
  let(:last_book_copies) { FactoryBot.create_list(:book_copy, 2, book: all_books.last) }

  path "/v1/librarian/books/{id}/book_copies" do
    get "Librarian List all book copies" do
      tags "Librarian Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"

      response(200, "book copies listed") do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   book_id: { type: :integer },
                   copy_code: { type: :string },
                   status: { type: :string },
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

    post "Librarian Create book copy" do
      tags "Librarian Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"
      parameter name: :params, in: :body, schema: {
        book_copy: {
          type: :object,
          properties: {
            type: :object,
            properties: {
              book_id: { type: :integer },
              status: { type: :string },
            },
            required: %w[book_id status],
          },
        },
      }

      response(201, "book copy created") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_id: { type: :integer },
                 copy_code: { type: :string },
                 status: { type: :string },
               }

        let(:id) { all_books.last.id }
        let(:params) { { book_copy: { book_id: all_books.last.id, status: BOOK_STATUSES[:available] } } }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "creates a book copy" do
          expect(response).to have_http_status(:created)
          expect(BookCopy.where(book_id: all_books.last.id).size).to eq(3)
        end
      end

      response(422, "invalid request") do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } },
               }

        let(:id) { all_books.last.id }
        let(:params) { { book_copy: { book_id: all_books.last.id, status: "unavailable" } } }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "returns an error" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(body["errors"]).to include("Status is not included in the list")
        end
      end
    end
  end

  path "/v1/librarian/books/{id}/book_copies/{book_copy_id}" do
    get "Librarian see a single book copy" do
      tags "Librarian Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"
      parameter name: :book_copy_id, in: :path, type: :string, required: true, description: "Book Copy ID"

      response(200, "book copy listed") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_id: { type: :integer },
                 copy_code: { type: :string },
                 status: { type: :string },
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

    patch "Librarian Update book copy" do
      tags "Librarian Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"
      parameter name: :book_copy_id, in: :path, type: :string, required: true, description: "Book Copy ID"
      parameter name: :params, in: :body, schema: {
        book_copy: {
          type: :object,
          properties: {
            type: :object,
            properties: {
              copy_code: { type: :string },
              status: { type: :string },
            },
            required: %w[copy_code status],
          },
        },
      }

      response(200, "book copy updated") do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 book_id: { type: :integer },
                 copy_code: { type: :string },
                 status: { type: :string },
               }

        let(:id) { all_books.last.id }
        let(:book_copy_id) { last_book_copies.first.id }
        let(:params) { { book_copy: { copy_code: "123456", status: BOOK_STATUSES[:borrowed] } } }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "updates book copy" do
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body["copy_code"]).to eq("123456")
        end
      end

      response(422, "invalid request") do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } },
               }

        let(:id) { all_books.last.id }
        let(:book_copy_id) { last_book_copies.first.id }
        let(:params) { { book_copy: { copy_code: "123456", status: "unavailable" } } }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "returns an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    delete "Librarian Delete book copy" do
      tags "Librarian Book Copies"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :id, in: :path, type: :string, required: true, description: "Book ID"
      parameter name: :book_copy_id, in: :path, type: :string, required: true, description: "Book Copy ID"

      response(204, "book copy deleted") do
        let(:id) { all_books.last.id }
        let(:book_copy_id) { last_book_copies.first.id }

        before do |example|
          first_book_copies
          last_book_copies
          submit_request(example.metadata)
        end

        it "deletes book copy" do
          expect(response).to have_http_status(:no_content)
          expect(BookCopy.find_by(id: last_book_copies.first.id)).to be_nil
        end
      end
    end
  end
end
