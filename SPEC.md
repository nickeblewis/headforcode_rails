# HeadForCode Rails Blog and Product Catalog Specification

## 1. Purpose

The application provides a public HeadForCode blog and a product catalog. The blog is based on the old HeadForCode site at `headforcode.com` and the source repository `NickLewisDigital/headforcode-2026`; the product workflow remains available as a separate Rails resource.

The public experience should feel editorial rather than administrative: a centered reading column, restrained white/stone surfaces, teal accents, rounded imagery, responsive post cards, strong typography, and dark-mode support. The product area can retain its catalog-oriented styling while sharing the site shell.

## 2. Users

### Visitor

- Browse published posts and available products.
- Open a post or product detail page.
- View article metadata, product information, images, categories, and tags.

### Catalog operator

- Create, edit, and delete or archive products.
- Replace product images and maintain product information.
- Find products quickly as the catalog grows.

### Author/editor

- Create and revise posts.
- Assign categories and tags.
- Upload hero and inline images.
- Save drafts, pin important posts, and publish on a chosen date.

### Administrator

- Manage operators and access rules.
- Review operational activity and production health.

Authentication and administrator behavior are future scope until the publishing workflow is proven.

## 3. Product Domain

### Required attributes

- `title`: short, human-readable product name.
- `description`: explanatory product copy.
- `price`: non-negative monetary amount with a consistent currency policy.

### Optional attributes

- `image`: one product image through Active Storage.

### Future attributes

- `slug` for stable, human-readable URLs.
- `status`: draft, published, archived.
- `sku` or external identifier.
- `currency` if more than one currency is supported.
- inventory quantity and availability.

### Rules

- Title must be present and limited to a documented maximum length.
- Description must be present when the product is published.
- Price must be present and greater than or equal to zero.
- Images must be limited by content type and file size.
- User-facing money must be formatted consistently; never rely on raw decimal output.
- Deleting a product must not leave orphaned attachments.

## 4. Blog Domain

### Post

- `title`: required, maximum 80 characters, displayed as the article heading.
- `slug`: required, unique, URL-safe identifier generated from the title and editable only with redirect handling.
- `description`: required short summary used in cards and metadata.
- `body`: required rich article content stored in a safe Markdown-compatible representation.
- `published_at`: required for published posts; controls ordering and future publication.
- `draft`: boolean, defaults to false; drafts never appear in public queries.
- `pinned`: boolean, defaults to false; pinned posts sort before regular posts on the home page.
- `reading_time_minutes`: derived from body content, not manually entered by default.
- `hero_image`: optional Active Storage attachment with a required alt text when present.
- `category`: belongs to one Category.
- `tags`: many-to-many through PostTag.

### Category

- `name`: required and unique, with an editable slug.
- Initial legacy categories: Services, App Development, Web Development, AI, and CMS.
- Journal, Music, Photography, Crypto, and History remain valid candidates from the import tooling and should be added only when content requires them.

### Tag

- `name`: required and normalized for case-insensitive uniqueness.
- `slug`: required and unique for `/tags/:slug` URLs.

### PostTag

- Joins posts and tags with a unique compound constraint.
- May later carry ordering or editorial metadata without changing the public post model.

### Future content models

- `Author` or User association when multi-author publishing is needed.
- `Redirect` for old slugs and imported URL aliases.
- `ContentImage` if inline image metadata, captions, or multiple renditions need first-class storage.
- `NewsletterSubscription`, `ContactMessage`, and `Comment` only after the core publishing workflow is stable.

### Blog rules

- Public queries include only non-draft posts whose publication date is not in the future.
- Home ordering is pinned first, then newest publication date descending.
- Category and tag pages use the same public scope and are paginated.
- Slugs are stable; changing one creates a redirect rather than silently breaking links.
- Raw HTML, Markdown, and imported MDX components must be sanitized or explicitly transformed before display.

## 5. User Flows

### Browse blog

1. Visitor opens `/` and sees the HeadForCode identity, a teal introductory callout, category links, and the latest published posts.
2. Post cards show hero image, category, publication date, reading time, title, and description.
3. Visitor can browse `/posts`, category pages, and tag pages with pagination.

### Read a post

1. Visitor opens `/posts/:slug`.
2. The page shows title, publication date, reading time, category, tags, hero image, and article body.
3. Headings produce a table of contents on larger screens.
4. The page offers related posts based on shared tags and simple share links.
5. The article exposes canonical and social metadata.

### Publish a post

1. Editor creates a post with title, description, body, publication date, category, tags, and optional hero image.
2. The post is saved as a draft until explicitly published.
3. Publishing makes it available to public queries and RSS.
4. Pinning places it ahead of non-pinned posts without changing its publication date.

### Import legacy content

1. An import task reads legacy MDX frontmatter and body content.
2. It normalizes titles, dates, categories, tags, slugs, draft/pinned state, and image references.
3. Dry-run mode reports new records, updates, collisions, unsupported MDX, and missing assets.
4. The task is idempotent and records the source path and checksum in an import manifest or equivalent metadata.

### Browse catalog

1. Visitor opens `/products`.
2. The page shows a responsive grid of product cards.
3. Each card presents image state, title, price, summary, and a clear detail action.
4. An empty catalog shows a useful empty state rather than a blank page.

### Create, edit, and delete products

1. Operator uses `/products/new` or `/products/:id/edit`.
2. Forms accept title, description, image, and price and preserve invalid input.
3. Successful mutations redirect to the relevant detail or index page with a notice.
4. Destructive actions require explicit confirmation and should archive rather than delete once external references exist.

## 6. Routes and Interfaces

### Blog HTML resource

- `GET /` - HeadForCode home with intro, categories, and latest posts.
- `GET /posts` - paginated post index.
- `GET /posts/:slug` - post detail.
- `GET /categories/:slug` - category listing.
- `GET /tags` - tag index.
- `GET /tags/:slug` - tag listing.
- `GET /search` - search results once search is implemented.

### Product HTML and JSON resource

- `GET /products`, `GET /products/new`, `POST /products`.
- `GET /products/:id`, `GET /products/:id/edit`.
- `PATCH/PUT /products/:id`, `DELETE /products/:id`.
- The resource supports JSON index, show, create, and update responses.

### Compatibility routes

- `GET /post/:slug` - legacy singular post URL, redirecting to `/posts/:slug` or serving the canonical page.
- `GET /category/:slug/:page` - legacy category URL, redirecting to `/categories/:slug` with pagination preserved where possible.
- `GET /tags/:slug` - retained as the canonical tag URL because it matches the old site.

### Feeds, metadata, and health

- `GET /rss.xml` returns published posts in RSS format.
- Sitemap includes posts, categories, tags, products, and the home page.
- Each public page has canonical, OpenGraph, and Twitter metadata.
- `GET /up` returns the Rails health status.

## 7. UI and Accessibility

- Use Rails `link_to`, `button_to`, and `form_with` helpers for actions and forms.
- Use Tailwind utility classes from the configured Rails content paths.
- Use the legacy visual direction as the starting point: `max-w-6xl` centered shell, `bg-white`/stone neutrals, teal callout and links, subtle borders, rounded-md/rounded-2xl imagery, 1/2/3-column post grids, and a prose-focused article layout.
- Provide a light/dark theme toggle with persisted preference and sufficient contrast in both modes.
- Give every action a clear text label and visible focus state.
- Use semantic headings, landmarks, labels, and button types.
- Provide useful alt text for product and hero images and explicit fallbacks when no image exists.
- Respect reduced-motion preferences; image hover effects must not be required to understand content.
- Support keyboard navigation and mobile widths without horizontal scrolling.

## 8. Technical Design

- Rails 8.1 with Active Record and PostgreSQL.
- `Product < ApplicationRecord` owns one Active Storage image.
- `Post < ApplicationRecord` belongs to Category, has many Tags through PostTag, and owns one Active Storage hero image.
- `Category`, `Tag`, and `PostTag` provide normalized taxonomy instead of storing comma-separated strings.
- Use a Markdown parser and sanitizer for imported/rendered body content; do not execute arbitrary MDX or HTML from imported posts.
- Use scopes such as `published`, `ordered_for_home`, and `for_category` to keep publication rules out of controllers and views.
- Import legacy content through a Rails task or service object with dry-run, idempotency, logging, and an import manifest.
- Product and blog behavior belongs in models and service objects, not view templates.
- Strong parameters remain in controllers.
- Tailwind input: `app/assets/stylesheets/application.tailwind.css`.
- Tailwind output: `app/assets/builds/application.css`.
- Development processes are defined in `Procfile.dev`.
- Production image storage must use durable object storage.

## 9. Testing Requirements

- Model tests cover product validations, monetary boundaries, attachment rules, post slug uniqueness, publication/draft scopes, pinned ordering, taxonomy relationships, and reading-time derivation.
- Request/system tests cover home, post index, post detail, category, tag, RSS, canonical metadata, pagination, legacy redirects, and every product route.
- View/system tests cover visible actions, form labels, image fallbacks, dark mode, and destructive action confirmation.
- Import tests cover frontmatter mapping, Markdown/MDX conversion, image copying, dry-run behavior, repeated imports, slug collisions, and unsupported components.
- Security tests confirm drafts and future posts are not publicly visible and imported content is sanitized.
- Asset checks confirm the Tailwind build succeeds from a clean install.
- CI runs Ruby tests, JavaScript/CSS build checks, RuboCop, Brakeman, and dependency auditing.

## 10. Non-Goals for the First Release

- Payments and checkout.
- Inventory reservation.
- Multi-tenant organizations.
- Recommendations or personalization.
- Native mobile applications.
- A full Tina-style CMS clone before the import and publishing workflow is understood.
- Runtime MDX execution in Rails.

## 11. Launch Acceptance Criteria

- A clean checkout can boot, migrate, seed, build assets, and run tests.
- Imported legacy posts appear with correct titles, dates, categories, tags, slugs, and available images.
- Public blog pages, legacy redirects, RSS, sitemap, and social metadata work for published content.
- Draft and future-dated posts remain private.
- Product creation, editing, browsing, and deletion work with valid and invalid inputs.
- Blog and product pages visually match the HeadForCode direction while remaining responsive and keyboard usable.
- Images are validated and stored durably in production.
- Unauthorized users cannot mutate catalog or editorial data once authentication is introduced.
- Monitoring, backups, and rollback steps are documented before production launch.
