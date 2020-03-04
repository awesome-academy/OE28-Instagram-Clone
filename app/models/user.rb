class User < ApplicationRecord
  enum gender: %i(female male)
  enum admin: %i(no yes)

  validates :name, presence: true,
    length: {maximum: Settings.user.max_length_name}
  validates :email, presence: true,
    length: {maximum: Settings.user.max_length_email},
    format: {with: Settings.user.email_regex},
    uniqueness: {case_sensitive: true}
  validates :username, presence: true,
    length: {
      maximum: Settings.user.max_length_username,
      minimum: Settings.user.min_length_username
    },
    format: {with: Settings.user.username_regex},
    uniqueness: {case_sensitive: true}
  validates :password, presence: true,
    length: {minimum: Settings.user.min_length_password}, allow_nil: true
  
  before_save :downcase_email

  has_secure_password
  
  def default_avatar_image
    Settings.user.default_avt
  end
  
  private
  
  def downcase_email
    email.downcase!
  end
end
