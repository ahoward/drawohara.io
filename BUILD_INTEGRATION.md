# Search Integration into Build Process

## Overview

The search functionality must be built **automatically** as part of the site build process. New pages added → next build → search works automatically.

## Build Steps

The search build requires 3 sequential steps:

1. `bin/generate-search-index` - Extracts page data from build/**/*.html → build/pages.json
2. `bin/build-lunr-index` - Builds search index from pages.json → build/search-index.json
3. `bin/generate-404-page` - Generates 404.html with embedded static page list

## Integration Options

### Option 1: Single Command (Recommended)

Add to your existing build script (e.g., `bin/build`, `Rakefile`, or `config/site.rb`):

```bash
# After HTML generation completes
bin/build-search
```

### Option 2: Individual Steps

If you need finer control, add each step separately:

```bash
# After your site builds HTML files
bin/generate-search-index
npx --yes lunr@2.3.9 bin/build-lunr-index
bin/generate-404-page
```

### Option 3: ro Integration

If using ro's build system, add to `config/site.rb`:

```ruby
# After site.build or in a post-build hook
system('bin/build-search') or raise "Search index build failed"
```

## GitHub Actions / CI Integration

Add to `.github/workflows/deploy.yml` or similar:

```yaml
- name: Build site
  run: |
    bundle exec site build  # or your build command
    bin/build-search       # auto-generate search index

- name: Deploy
  # ... deploy build/ directory including 404.html, pages.json, search-index.json
```

## Verification

After integration, verify:

```bash
# Run your normal build
site build  # (or whatever your command is)

# Check files were created
ls -lh build/404.html build/pages.json build/search-index.json

# Test locally
cd build && python3 -m http.server 8000
# Navigate to http://localhost:8000/nonexistent-page
```

## GitHub Pages Configuration

GitHub Pages automatically serves `404.html` for missing pages. No additional configuration needed.

## Dependencies

- **Ruby**: nokogiri gem (should already be installed)
- **Node.js**: lunr@2.3.9 (installed via npm, called via npx)

## Files Generated

- `build/pages.json` - Page metadata for search (title, href, content excerpt)
- `build/search-index.json` - Pre-built lunr.js search index  
- `build/404.html` - 404 page with search UI and static page list

## Performance

- Build overhead: ~5-10 seconds for 500 pages
- Index size: ~35-50 KB (gzipped)
- Search response: <100ms client-side
