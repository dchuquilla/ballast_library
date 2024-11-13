# frozen_string_literal: true

class V1::Librarian::BooksController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_book, only: [:show, :update, :destroy]

  before_action only: [:create, :update, :destroy] do
    authorize(@book || Book, "#{params[:action]}?")
  end

  def index
    @books = Book.all
    render json: @books, status: :ok
  end

  def search
    @books = BookSearchService.new(params[:query]).call
    render json: @books, status: :ok
  end

  def show
    render json: @book, status: :ok
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    head :no_content
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn)
  end
end
