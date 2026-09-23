require "rails_helper"

RSpec.describe Post, type: :model do
  let!(:category) { Category.create!(name: "Web Development", slug: "web-development") }

  it "generates a slug and reading time" do
    post = described_class.create!(title: "A New Post", description: "Summary", body: "one two three", category: category, draft: false, published_at: 1.day.ago)

    expect(post.slug).to eq("a-new-post")
    expect(post.reading_time_minutes).to eq(1)
  end

  it "only publishes non-draft posts whose publication date has arrived" do
    published = described_class.create!(title: "Published", description: "Summary", body: "Body", category: category, draft: false, published_at: 1.day.ago)
    described_class.create!(title: "Draft", description: "Summary", body: "Body", category: category, draft: true, published_at: 1.day.ago)
    described_class.create!(title: "Future", description: "Summary", body: "Body", category: category, draft: false, published_at: 1.day.from_now)

    expect(described_class.published).to contain_exactly(published)
  end
end
