class Business < ApplicationRecord
  has_secure_password
  has_many :products

  before_validation :normalize_email

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            format: {
              with: /\A(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}\z/,
              message: 'must include at least one uppercase letter, one lowercase letter, one digit, and one special character'
            },
            if: -> { new_record? || !password.nil? }
  validates :business_type, presence: true, inclusion: { in: %w[retail wholesale manufacturing] }
  validates :status, presence: true, inclusion: { in: %w[pending active suspended] }

  def suspend
    update!(status: 'suspended')
  end

  def activate
    update!(status: 'active')
  end

private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end