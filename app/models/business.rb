class Business < ApplicationRecord
  has_secure_password
  has_many :products

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :business_type, presence: true, inclusion: { in: %w[retail wholesale manufacturing] }
  validates :status, presence: true, inclusion: { in: %w[pending active suspended] }

  def suspend
    update!(status: 'suspended')
  end

  def activate
    update!(status: 'active')
  end
end