class PostsController < ApplicationController
  before_action :set_post, only: :show

  def index
    @posts = Post.published.includes(:category, :tags).ordered_for_home
  end

  def show
    @related_posts = Post.published.where(category: @post.category).where.not(id: @post.id).ordered_for_home.limit(3)
  end

  def category
    @category = Category.find_by!(slug: params[:slug])
    @posts = @category.posts.published.includes(:category, :tags).ordered_for_home
  end

  def tags
    @tag = Tag.find_by!(slug: params[:slug])
    @posts = @tag.posts.published.includes(:category, :tags).ordered_for_home
  end

  def tags_index
    @tags = Tag.order(:name)
  end

  private

  def set_post
    @post = Post.published.includes(:category, :tags).find_by!(slug: params[:slug])
  end
end
