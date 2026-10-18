ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
ActiveRecord.maintain_test_schema = false # Test command explicitly migrates the pre-created database.
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

require "base64"
require "openssl"

module TokenTestHelper
  def token_for(subject)
    header = Base64.urlsafe_encode64({ alg: "HS256", typ: "JWT" }.to_json, padding: false)
    payload = Base64.urlsafe_encode64({ sub: subject, iss: "cant-run-alone-local", aud: "cant-run-alone-services", iat: Time.now.to_i, exp: Time.now.to_i + 900 }.to_json, padding: false)
    signature = Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", ENV.fetch("JWT_SECRET"), "#{header}.#{payload}"), padding: false)
    "Bearer #{header}.#{payload}.#{signature}"
  end

  def call_for(subject)
    Struct.new(:metadata).new({ "authorization" => token_for(subject) })
  end
end

ActiveSupport::TestCase.include(TokenTestHelper)
