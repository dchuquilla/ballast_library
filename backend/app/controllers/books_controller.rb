class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @books = Book.all
    render json: @books, status: :ok
  end

  def show
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
end
