namespace :legacy do
  desc "Import posts from the legacy HeadForCode Astro repository"
  task :import, [:source_path] => :environment do |_task, args|
    source_path = Pathname.new(args[:source_path].presence || ENV["SOURCE_PATH"].to_s)
    blog_path = source_path.join("src", "content", "blog")

    abort "Usage: bin/rails legacy:import[/path/to/headforcode-2026]" unless blog_path.directory?

    imported = 0
    skipped = 0

    blog_path.glob("*.md*").each do |file_path|
      raw = file_path.read
      frontmatter, body = raw.split(/^---\s*$\n/, 3).then { |parts| [parts[1], parts[2]] }
      next skipped += 1 unless frontmatter && body

      attributes = YAML.safe_load(frontmatter, permitted_classes: [Date, Time], aliases: true) || {}
      title = attributes.fetch("title")
      slug = file_path.basename.sub_ext("").to_s.parameterize
      category_name = attributes["category"].presence || "Journal"
      category = Category.find_or_create_by!(name: category_name) do |record|
        record.slug = category_name.parameterize
      end

      post = Post.find_or_initialize_by(slug: slug)
      post.assign_attributes(
        title: title,
        description: attributes["description"].presence || body.lines.find { |line| line.present? }.to_s.strip,
        body: body.strip,
        published_at: attributes["pubDate"].presence && Time.zone.parse(attributes["pubDate"].to_s),
        draft: attributes.fetch("draft", false),
        pinned: attributes.fetch("pinned", false),
        category: category
      )
      post.save!

      Array(attributes["tags"]).each do |tag_name|
        tag = Tag.find_or_create_by!(name: tag_name.to_s.downcase.strip) do |record|
          record.slug = tag_name.to_s.parameterize
        end
        post.tags << tag unless post.tags.exists?(tag.id)
      end

      hero_image = attributes["heroImage"].to_s.sub(%r{^/}, "")
      image_path = source_path.join("public", hero_image)
      if hero_image.present? && image_path.file? && !post.hero_image.attached?
        post.hero_image.attach(io: File.open(image_path), filename: image_path.basename.to_s, content_type: Marcel::MimeType.for(image_path))
        post.update!(hero_image_alt: title)
      end

      imported += 1
      puts "Imported #{post.slug}"
    rescue KeyError => error
      warn "Skipped #{file_path}: #{error.message}"
      skipped += 1
    end

    puts "Imported #{imported} posts; skipped #{skipped}."
  end
end
