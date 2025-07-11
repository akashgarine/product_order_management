class User < ApplicationRecord
  has_secure_password
  has_many :orders

  before_validation :normalize_email
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            format: {
              with: /\A(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}\z/,
              message: 'must include at least one uppercase letter, one lowercase letter, one digit, and one special character'
            },
            if: -> { new_record? || !password.nil? }
  validates :role, presence: true, inclusion: { in: %w[customer admin] }
  validates :preferences, presence: true


  def suspend
    update!(active: false)
  end

  def activate
    update!(active: true)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
