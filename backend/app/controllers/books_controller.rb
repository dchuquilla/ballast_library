class BooksController < ApplicationController
  include AuthorizationHelper

  before_action :authenticate_user!
  before_action :set_book, only: [:show, :update, :destroy]
  before_action only: [:create, :update, :destroy] do
    authorize(@book || Book)
  end

  def index
    @books = Book.all
    render json: @books, status: :ok
  end

  def show
    render json: @book, status: :ok
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end
end
