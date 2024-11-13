require "faker"

# Create users
member = User.find_or_create_by(email: "member@example.com") do |user|
  user.name = "Member"
  user.password = "Mpassword"
  user.password_confirmation = "Mpassword"
  user.role = APP_ROLES[:member]
end
member.save!

puts "Member created with email #{User.last.email}"

librarian = User.find_or_create_by(email: "librarian@example.com") do |user|
  user.name = "Librarian"
  user.password = "Lpassword"
  user.password_confirmation = "Lpassword"
  user.role = APP_ROLES[:librarian]
end
librarian.save!

puts "Librarian created with email #{User.last.email}"

(1..50).each do |n|
  Book.create!(
    title: Faker::Book.title,
    author: Faker::Book.author,
    genre: Faker::Book.genre,
    isbn: Faker::Code.isbn,
  )

  puts "Book created with title '#{Book.last.title}'"

  (1..3).each do |m|
    BookCopy.create!(
      book_id: Book.last.id,
      status: BOOK_STATUSES[:available],
    )

    puts "  - Book copy created for book with code [#{BookCopy.last.copy_code}]"
  end
end

(1..5).each do |n|
  Borrowing.create!(
    user_id: member.id,
    book_copy_id: BookCopy.all.sample.id,
  )

  puts "Borrowing created for user with email '#{User.find(Borrowing.last.user_id).email}'"
end

(1..5).each do |n|
  Borrowing.create!(
    user_id: member.id,
    book_copy_id: BookCopy.all.sample.id,
    due_date: Faker::Date.backward(days: 30), # Set due date in the past to simulate overdue
  )

  puts "Overdue borrowing created for user with email '#{User.find(Borrowing.last.user_id).email}'"
end
