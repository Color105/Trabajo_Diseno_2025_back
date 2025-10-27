# app/models/user.rb
class User < ApplicationRecord
  # requiere gem 'bcrypt' y columna password_digest
  has_secure_password

  # Si usás enum para role (opcional, ajustá a tu BD)
  # enum role: { admin: 0, consultor: 1, cliente: 2 }, _prefix: :role
  # Si usás string en role, podés validar inclusión:
  validates :role, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  before_validation :downcase_email

  private

  def downcase_email
    self.email = email.to_s.downcase
  end
end
