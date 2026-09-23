require "rails_helper"

RSpec.describe "Blog", type: :request do
  let!(:category) { Category.create!(name: "CMS", slug: "cms") }
  let!(:post) do
    Post.create!(
      title: "The Modern CMS",
      slug: "the-modern-cms",
      description: "A short summary",
      body: "## Content\n\nA useful post.",
      category: category,
      draft: false,
      published_at: 1.day.ago
    )
  end

  it "renders the home page and published post" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("The Modern CMS")
  end

  it "renders a post from its slug" do
    get post_path(post)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("A useful post.")
  end

  it "keeps drafts out of public routes" do
    draft = Post.create!(title: "Private", description: "Summary", body: "Body", category: category, draft: true)

    get post_path(draft)

    expect(response).to have_http_status(:not_found)
  end
end
