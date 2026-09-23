require "commonmarker"

module BlogHelper
  def render_post_body(markdown)
    html = Commonmarker.to_html(markdown.to_s)
    sanitize(html, tags: %w[h1 h2 h3 h4 h5 h6 p a ul ol li blockquote pre code strong em del img hr], attributes: %w[href src alt title class id target rel])
  end
end
