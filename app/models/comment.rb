class Comment < ApplicationRecord
  include CommentConcern

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: Comment.name, optional: true

  has_many :replies, class_name: Comment.name, foreign_key: :parent_id,
    dependent: :destroy

  validates :content, presence: true
  validates :user_id, presence: true
  validates :post_id, presence: true

  delegate :username, to: :user, prefix: :user
  delegate :user, to: :post, prefix: :post_owner

  scope :order_by_created_at, ->{order :created_at}
  scope :top, (lambda do |post_id|
    where(post_id: post_id)
    .order(created_at: :desc)
    .limit(Settings.top_comments)
  end)
end
