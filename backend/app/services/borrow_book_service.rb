# frozen_string_literal: true

class BorrowBookService
  attr_reader :user, :params, :borrowing, :errors

  def initialize(user, params)
    @user = user
    @params = params
    @errors = []
  end

  def call
    @borrowing = Borrowing.new(user: user, book_copy_id: params[:book_copy_id])

    if @borrowing.save
      book_copy = BookCopy.find(params[:book_copy_id])
      book_copy.update(status: BOOK_STATUSES[:borrowed])

      { success: true, message: "Book borrowed successfully", borrowing: @borrowing }
    else
      @errors = @borrowing.errors.full_messages
      { success: false, errors: @errors }
    end
  end
end
