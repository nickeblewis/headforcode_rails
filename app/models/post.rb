class Post < ApplicationRecord
  belongs_to :category
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_one_attached :hero_image

  scope :published, -> { where(draft: false).where("published_at IS NULL OR published_at <= ?", Time.current) }
  scope :ordered_for_home, -> { order(pinned: :desc, published_at: :desc, created_at: :desc) }

  validates :title, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true
  validates :description, :body, presence: true
  validates :reading_time_minutes, numericality: { only_integer: true, greater_than: 0 }

  before_validation :normalize_slug
  before_validation :calculate_reading_time

  def to_param
    slug
  end

  private

  def normalize_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def calculate_reading_time
    words = body.to_s.scan(/\S+/).length
    self.reading_time_minutes = [(words / 200.0).ceil, 1].max
  end
end
