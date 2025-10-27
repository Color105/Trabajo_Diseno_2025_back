# app/services/json_web_token.rb
class JsonWebToken
  SECRET = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET'] || 'dev-secret'

  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.merge(exp: exp.to_i)
    JWT.encode(payload, SECRET, 'HS256')
  end

  def self.decode(token)
    return nil if token.blank?
    body, = JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
