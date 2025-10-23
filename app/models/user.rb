# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # enum correcto (sí recibe un hash)
  enum :role, { admin: 0, recepcionista: 1, cliente: 2 }

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: /\A[^@\s]+@[^@\s]+\z/ }
end
