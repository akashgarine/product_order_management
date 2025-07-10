class User < ApplicationRecord
  has_secure_password
  has_many :orders

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :role, presence: true, inclusion: { in: %w[customer admin] }
  validates :preferences, presence: true

  def suspend
    update!(active: false)
  end

  def activate
    update!(active: true)
  end
end