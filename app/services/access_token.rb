require "base64"
require "json"
require "openssl"

module AccessToken
  class Invalid < StandardError; end

  def self.subject(header)
    scheme, token = header.to_s.split(" ", 2)
    raise Invalid unless scheme&.downcase == "bearer" && token
    parts = token.split(".")
    raise Invalid unless parts.length == 3
    metadata = JSON.parse(Base64.urlsafe_decode64(parts[0]))
    raise Invalid unless metadata["alg"] == "HS256"
    expected = OpenSSL::HMAC.digest("SHA256", ENV.fetch("JWT_SECRET"), parts.first(2).join("."))
    signature = Base64.urlsafe_decode64(parts[2])
    raise Invalid unless signature.bytesize == expected.bytesize && OpenSSL.fixed_length_secure_compare(signature, expected)
    claims = JSON.parse(Base64.urlsafe_decode64(parts[1]))
    raise Invalid unless claims["iss"] == "cant-run-alone-local" && claims["aud"] == "cant-run-alone-services"
    raise Invalid unless claims["exp"].is_a?(Numeric) && claims["exp"] > Time.now.to_i
    raise Invalid unless claims["iat"].is_a?(Numeric) && claims["iat"] <= Time.now.to_i + 30
    subject = claims.fetch("sub")
    raise Invalid unless subject.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    subject
  rescue JSON::ParserError, ArgumentError, KeyError, TypeError
    raise Invalid
  end
end
