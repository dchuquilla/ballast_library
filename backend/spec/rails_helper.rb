require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "factory_bot_rails"
require "support/factory_bot"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
