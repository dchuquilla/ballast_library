# frozen_string_literal: true

class V1::Member::BooksController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_book, only: [:show]

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

  private

  def set_book
    @book = Book.find(params[:id])
  end
end
