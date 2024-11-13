require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = FactoryBot.create(:user)
    librarian = FactoryBot.create(:user, :librarian)

    expect(user).to be_valid
    expect(librarian).to be_valid
  end

  it "is not valid without a name" do
    user = FactoryBot.build(:user, name: nil)
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = FactoryBot.build(:user, email: nil)
    expect(user).to_not be_valid
  end

  it "is not valid without a role" do
    user = FactoryBot.build(:user, role: nil)
    expect(user).to_not be_valid
  end

  it "is not valid with unknown role" do
    user = FactoryBot.build(:user, role: "unknown")
    expect(user).to_not be_valid
  end
end
