class CreateBlogContent < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :categories, :name, unique: true
    add_index :categories, :slug, unique: true

    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :description, null: false
      t.text :body, null: false
      t.datetime :published_at
      t.boolean :draft, null: false, default: true
      t.boolean :pinned, null: false, default: false
      t.integer :reading_time_minutes, null: false, default: 1
      t.string :hero_image_alt
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, [:draft, :published_at]
    add_index :posts, [:pinned, :published_at]

    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true

    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :post_tags, [:post_id, :tag_id], unique: true
  end
end
