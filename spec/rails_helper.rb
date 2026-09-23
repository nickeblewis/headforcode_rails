ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rspec/rails"
require_relative "spec_helper"

abort("The Rails environment is running in production mode!") if Rails.env.production?

begin
  ActiveRecord::Migration.check_all_pending!
rescue ActiveRecord::PendingMigrationError => error
  abort error.message
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures")]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
