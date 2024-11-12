class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, uniqueness: true, presence: true
  validates :role, presence: true, inclusion: { in: APP_ROLES }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :password_confirmation, presence: true, if: -> { new_record? || !password.nil? }
end
