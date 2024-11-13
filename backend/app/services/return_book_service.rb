class ReturnBookService
  attr_reader :borrowing, :errors

  def initialize(borrowing)
    @borrowing = borrowing
    @errors = []
  end

  def call
    if @borrowing.update(returned_at: Time.current)
      @borrowing.book_copy.update(status: BOOK_STATUSES[:available])
      { success: true, borrowing: @borrowing }
    else
      @errors = @borrowing.errors.full_messages
      @borrowing.book_copy.update(status: BOOK_STATUSES[:borrowed])
      { success: false, errors: @errors }
    end
  end
end
