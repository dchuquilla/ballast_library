class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true
  validates :email, uniqueness: true, presence: true
  validates :role, presence: true, inclusion: { in: APP_ROLES.values }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :password_confirmation, presence: true, if: -> { new_record? || !password.nil? }

  def librarian?
    role == APP_ROLES[:librarian]
  end

  def member?
    role == APP_ROLES[:member]
  end
end
