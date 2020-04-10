class User < ApplicationRecord
  include UserConcern
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]
  enum gender: {female: 0, male: 1, other: 2}
  enum role: {user: 0, admin: 1}
  enum status: {public_mode: 0, private_mode: 1}

  USER_PARAMS = %i(email name uid username password password_confirmation).freeze
  USER_PARAMS_UPDATE = %i(email name username website
                          bio phone gender status avatar_image).freeze

  has_many :posts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :bookmark_likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :active_notifications, class_name: Notification.name,
    foreign_key: :sender_id, dependent: :destroy
  has_many :passive_notifications, class_name: Notification.name,
    foreign_key: :receiver_id, dependent: :destroy
  has_many :senders, through: :passive_notifications, source: :sender

  validates :name, presence: true,
    length: {maximum: Settings.user.max_length_name}
  validates :email, presence: true,
    length: {maximum: Settings.user.max_length_email},
    format: {with: Settings.user.email_regex},
    uniqueness: {case_sensitive: false}
  validates :username, presence: true,
    length: {
      maximum: Settings.user.max_length_username,
      minimum: Settings.user.min_length_username
    },
    format: {with: Settings.user.username_regex},
    uniqueness: {case_sensitive: false}
  validates :phone, allow_blank: true,
    format: {with: Settings.user.phone_regex}

  before_save :downcase_email
  has_one_attached :avatar_image

  scope :likers_to_likeable, (lambda do |likeable_id, likeable_type|
    joins(:bookmark_likes).where(
      "bookmark_likes.type_action": Settings.bookmark_like.like,
      "bookmark_likes.likeable_id": likeable_id,
      "bookmark_likes.likeable_type": likeable_type
    )
  end)

  scope :search_by_name_username, (lambda do |sample_string|
    where("username LIKE :search OR name LIKE :search",
          search: "%#{sample_string}%")
  end)

  scope :order_by_created_at, ->{order created_at: :desc}
  scope :order_by_updated_at, ->{order updated_at: :desc}
  scope :order_by_name, ->{order :name}
  scope :order_by_username, ->{order :username}

  def bookmarking? post
    Post.bookmarking_by_user(id).include? post
  end

  private

  def downcase_email
    email.downcase!
  end
end
