# HeadForCode Rails Delivery Plan

## Product Direction

Build HeadForCode as a Rails-based home for two connected surfaces:

- A public blog based on the old HeadForCode site, covering web development, app development, AI, CMS work, photography, music, and personal journal content.
- A product catalog that lets an operator create, maintain, browse, and share products with clear images, descriptions, and prices.

The blog is the next major product surface. It should preserve the old site's editorial character and migrate its existing content, while the products side remains available at `/products` and evolves independently.

## Current Baseline

- Rails 8.1 application with PostgreSQL support.
- `Product` CRUD at `/products`, with title, description, price, and one attached image.
- HTML and JSON responses for the product resource.
- Tailwind CSS 4 through `cssbundling-rails` and a watched `Procfile.dev` process.
- Active Storage configured for local development.
- Health check at `/up`.
- Legacy source at `NickLewisDigital/headforcode-2026`, an Astro/Tailwind blog with MDX content, Tina CMS, categories, tags, drafts, pinned posts, reading time, related posts, table of contents, RSS, search, sharing, and pagination.
- No blog models, authentication, authorization, search, pagination, product status, or checkout yet.

## Milestones

### 0. Stabilize the foundation

- Add request, model, and view test infrastructure that runs from a clean checkout.
- Add product validations and database constraints for required fields and valid prices.
- Add seed data and a documented setup path.
- Decide the public information architecture: blog home at `/`, posts at `/posts/:slug`, and products at `/products`.
- Make the root route point to the blog home.
- Confirm Tailwind builds in development and production.

**Exit criteria:** A new developer can set up the app, run the test suite, build assets, and see a working blog home and product catalog without manual database repair.

### 1. Build the blog foundation

- Add `Post`, `Category`, `Tag`, and `PostTag` models and migrations.
- Add post fields for title, slug, description, body, publication date, draft state, pinned state, category, reading time, and hero image.
- Add unique, normalized slugs and tag/category relationships.
- Add blog index, post detail, category, and tag routes.
- Render Markdown content safely and support headings, links, lists, blockquotes, images, and syntax-highlighted code.
- Add canonical URLs, OpenGraph/Twitter cards, sitemap, and RSS.

**Exit criteria:** A seeded post can be published at a stable slug, discovered from the home page, filtered by category/tag, and rendered as a readable article.

### 2. Import and match the old site

- Inventory every post in `src/content/blog` from the legacy repository and preserve title, description, publication date, hero image, category, tags, draft, and pinned status.
- Build an idempotent import task with dry-run output, slug collision reporting, and an import manifest.
- Convert MDX to a supported Rails content format or sanitized HTML/Markdown representation.
- Copy or rehost hero and inline images through Active Storage, preserving original attribution and alt text where available.
- Add redirects from legacy `/post/:slug/`, `/category/:category/:page`, and `/tags/:tag` URLs where slugs change.
- Compare imported post counts, links, images, and published dates against the legacy site before switching traffic.

**Exit criteria:** The public blog contains the legacy content with no avoidable broken links or missing hero images, and the import can be safely rerun.

### 3. Recreate the editorial experience

- Build a shared site shell with the old site's centered max-width layout, teal callout, stone/white palette, rounded image treatment, and responsive spacing.
- Add post cards with hero image, category, publication date, reading time, title, description, and a clear link.
- Add article metadata, tag pills, table of contents, related posts, share actions, and a readable prose column.
- Add dark mode, reduced-motion support, keyboard-visible focus states, and responsive mobile layouts.
- Add pagination and search after the imported content is available.

**Exit criteria:** The Rails blog feels recognizably like HeadForCode while remaining accessible, server-rendered, and maintainable with Rails view helpers.

### 4. Complete the catalog experience

- Improve product cards and detail pages for empty, missing, and broken image states.
- Add image validation, previews, alt text, and removal/replacement behavior.
- Add search by title and description.
- Add sorting and pagination once the catalog can grow beyond one page.
- Add empty states and useful validation messages.

**Exit criteria:** An operator can find and maintain products quickly on desktop and mobile, and visitors can understand each product from the index and detail pages.

### 5. Add operator access

- Introduce user accounts and authentication.
- Restrict post publishing and product mutations to authorized users.
- Define ownership or team-level access rules.
- Add audit-friendly timestamps and a safe delete/archive policy.

**Exit criteria:** Anonymous visitors can browse published posts and products, while only authorized operators can change catalog or editorial data.

### 6. Prepare for commerce or inquiry workflows

Choose one direction based on product requirements:

- Inquiry flow: contact request tied to one or more products.
- Commerce flow: cart, order, payment provider, fulfillment status, and transactional emails.

Keep this separate from catalog correctness and publishing so payments or fulfillment do not destabilize the core site.

### 7. Production readiness

- Configure production storage and image processing.
- Add error monitoring, structured logs, backups, and health checks.
- Add CI for Ruby, JavaScript/CSS, security, and asset builds.
- Review accessibility, performance, and responsive behavior.
- Document deployment and rollback procedures.

**Exit criteria:** The app can be deployed, monitored, backed up, and rolled back by someone other than the original implementer.

## Working Order

1. Foundation tests, validations, root route, seeds, and setup documentation.
2. Blog models, routes, rendering, and publication rules.
3. Legacy content and image import with redirect coverage.
4. HeadForCode editorial styling, metadata, search, pagination, and RSS.
5. Catalog quality: images, search, sorting, pagination, and empty states.
6. Authentication and authorization.
7. Inquiry or commerce workflow decision and implementation.
8. Production operations and launch review.

## Risks and Decisions

- **Content format:** Prefer a normalized database-backed post model for the Rails application. Retain original MDX files and the import manifest as migration/audit inputs rather than coupling runtime rendering to Astro.
- **MDX compatibility:** Some legacy posts may contain components or syntax Rails cannot render directly. Import those as drafts or sanitized Markdown and report unsupported blocks for manual review.
- **URL continuity:** Existing search traffic depends on `/post`, `/category`, and `/tags` paths; preserve them or add permanent redirects before launch.
- **Editorial ownership:** Decide whether the first editor is the repository/seed workflow or an authenticated admin UI. Do not add Tina CMS by assumption.
- **Image storage:** Local storage is development-only; production needs durable object storage and a cleanup policy.
- **Search scale:** Database filtering is enough for an early catalog and blog. Introduce a search service only when query volume or relevance requires it.
- **Deletion:** Prefer archiving once products or posts are referenced by orders, inquiries, or external links.
- **Test setup:** The repository contains generated RSpec files but lacks a working `spec/rails_helper.rb`; fix this during milestone 0.
