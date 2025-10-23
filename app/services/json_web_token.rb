# app/services/json_web_token.rb
require "jwt"

module JsonWebToken
  module_function

  def encode(payload, exp: 24.hours.from_now)
    data = payload.dup
    data[:exp] = exp.to_i
    JWT.encode(data, secret_key, "HS256")
  end

  def decode(token)
    body, = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
    body.deep_symbolize_keys
  rescue JWT::ExpiredSignature
    raise StandardError, "Token expirado"
  rescue JWT::DecodeError => e
    raise StandardError, "Token inválido: #{e.message}"
  end

  def secret_key
    Rails.application.credentials.dig(:jwt, :secret) ||
      ENV["JWT_SECRET"] ||
      Rails.application.secret_key_base
  end
end
