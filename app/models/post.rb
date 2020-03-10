class Post < ApplicationRecord
  include PostConcern

  belongs_to :user
  has_many :post_hashtags, dependent: :destroy
  has_many :hashtags, through: :post_hashtags
  has_many_attached :images

  delegate :name, :username, to: :user, prefix: :user

  validates :user_id, presence: true
  validates :images, content_type: {in: Settings.post.content_type,
                                    message: I18n.t("must_be_valid_format")},
    size: {less_than: Settings.post.max_picture_size.megabytes,
           message: I18n.t("less_than_max_size")}
  validate :image_presence

  scope :order_by_created_at, ->{order created_at: :desc}

  after_commit :add_hashtags, on: %i(create update)
  
  private
  def image_presence
    errors.add :images, I18n.t("image_cant_be_blank") unless images.attached?
  end
end
