# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

# Run Coverage report
require 'solidus_dev_support/rspec/coverage'
require "shoulda/matchers"

# Create the dummy app if it's still missing.
dummy_env = "#{__dir__}/dummy/config/environment.rb"
system 'bin/rake extension:test_app' unless File.exist? dummy_env
require dummy_env

# Requires factories and other useful helpers defined in spree_core.
require 'solidus_dev_support/rspec/feature_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Requires factories defined in lib/solidus_paypal_marketplace/testing_support/factories.rb
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusPaypalMarketplace::Engine)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  if Spree.solidus_gem_version < Gem::Version.new('2.11')
    config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :system
  end
  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
