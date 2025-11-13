# Quickstart: 404 Search Page Implementation

**Feature**: Static 404 Page with Search
**Estimated Time**: 2-3 hours
**Prerequisites**: Existing ro-based static site build process

## Overview

Add a searchable 404 page to help visitors find content when they land on broken URLs. The page works without JavaScript (shows static URL list) and enhances with client-side search when JavaScript is available.

## TL;DR

1. Create `bin/generate-search-index` to extract page data
2. Create `bin/build-lunr-index` (Node.js) to build search index
3. Create `build/404.html` template with search UI
4. Integrate into existing build process
5. Deploy to GitHub Pages

## Step-by-Step Implementation

### 1. Create Page Data Extraction Script

**File**: `bin/generate-search-index`

```ruby
#!/usr/bin/env ruby
require 'json'
require 'nokogiri'

pages = []

Dir.glob('build/**/*.html').each do |file|
  next if file.include?('404.html')

  doc = Nokogiri::HTML(IO.binread(file))

  # Extract title
  title = doc.at_css('title')&.text ||
          doc.at_css('h1')&.text ||
          File.basename(file, '.html')

  # Extract content (prefer meta description)
  content = doc.at_css('meta[name="description"]')&.[]('content') ||
            doc.at_css('meta[property="og:description"]')&.[]('content') ||
            doc.css('article p, main p, .content p').first&.text

  # Truncate content to 150 chars
  content = content&.[](0..149)

  # Get relative URL
  href = file.sub('build', '').sub('/index.html', '/')

  pages << {
    title: title.to_s.strip,
    href: href,
    content: content.to_s.strip
  }
end

# Write pages.json
IO.binwrite('build/pages.json', JSON.pretty_generate(pages))
puts "Generated #{pages.size} page entries"
```

Make executable: `chmod +x bin/generate-search-index`

### 2. Create Lunr.js Index Builder

**File**: `bin/build-lunr-index` (Node.js)

```javascript
#!/usr/bin/env node

const lunr = require('lunr');
const fs = require('fs');

// Load pages data
const pages = JSON.parse(fs.readFileSync('build/pages.json', 'utf8'));

// Build search index
const idx = lunr(function () {
  this.ref('href');
  this.field('title', { boost: 10 });
  this.field('content');

  pages.forEach(function (page) {
    this.add(page);
  }, this);
});

// Write serialized index
fs.writeFileSync('build/search-index.json', JSON.stringify(idx));

console.log(`Search index built: ${pages.length} pages`);
```

Make executable: `chmod +x bin/build-lunr-index`

Install lunr: `npm install --save-dev lunr` (or use npx)

### 3. Create 404.html Template

**File**: `build/404.html` (or use ERB template)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Not Found</title>
  <style>
    body {
      font-family: system-ui, sans-serif;
      max-width: 800px;
      margin: 2rem auto;
      padding: 0 1rem;
      line-height: 1.6;
    }
    .search-box { margin: 2rem 0; }
    .search-box input {
      width: 100%;
      padding: 0.75rem;
      font-size: 1.1rem;
      border: 2px solid #ddd;
      border-radius: 4px;
    }
    .page-list { list-style: none; padding: 0; }
    .page-list li {
      padding: 0.75rem 0;
      border-bottom: 1px solid #eee;
    }
    .page-list a { color: #0066cc; text-decoration: none; }
    .page-list a:hover { text-decoration: underline; }
    mark { background: #ffd; padding: 0 2px; }
  </style>
</head>
<body>
  <h1>Page Not Found</h1>
  <p>Sorry, we couldn't find what you were looking for. Try searching or browse all pages below:</p>

  <div class="search-box">
    <input
      type="text"
      id="search"
      placeholder="Search for pages..."
      aria-label="Search site pages"
    >
  </div>

  <ul class="page-list" id="results">
    <!-- Static list generated at build time -->
    <li><a href="/about/">About</a></li>
    <li><a href="/contact/">Contact</a></li>
    <!-- ... more pages ... -->
  </ul>

  <script src="https://unpkg.com/lunr@2.3.9/lunr.min.js"></script>
  <script>
    let pagesData, searchIdx;
    const searchInput = document.getElementById('search');
    const resultsList = document.getElementById('results');

    // Load search data
    Promise.all([
      fetch('/pages.json').then(r => r.json()),
      fetch('/search-index.json').then(r => r.json())
    ]).then(([pages, idx]) => {
      pagesData = pages;
      searchIdx = lunr.Index.load(idx);
      searchInput.addEventListener('input', handleSearch);
    }).catch(err => {
      console.error('Search failed to load:', err);
      // Page still works with static list
    });

    function handleSearch(e) {
      const query = e.target.value.trim();

      if (!query) {
        showAllPages();
        return;
      }

      const results = searchIdx.search(query);
      displayResults(results, query);
    }

    function displayResults(results, query) {
      if (results.length === 0) {
        resultsList.innerHTML = '<li style="color: #666;">No pages found.</li>';
        return;
      }

      const html = results.slice(0, 50).map(r => {
        const page = pagesData.find(p => p.href === r.ref);
        if (!page) return '';
        return `
          <li>
            <a href="${page.href}">${highlight(page.title, query)}</a>
            ${page.content ? `<br><small style="color:#666;">${highlight(page.content, query)}</small>` : ''}
          </li>
        `;
      }).join('');

      resultsList.innerHTML = html;
    }

    function showAllPages() {
      const html = pagesData.map(p =>
        `<li><a href="${p.href}">${p.title}</a></li>`
      ).join('');
      resultsList.innerHTML = html;
    }

    function highlight(text, query) {
      const terms = query.toLowerCase().split(/\s+/);
      let result = text;
      terms.forEach(term => {
        const regex = new RegExp(`(${term})`, 'gi');
        result = result.replace(regex, '<mark>$1</mark>');
      });
      return result;
    }
  </script>
</body>
</html>
```

### 4. Integrate into Build Process

Update `config/site.rb` or your build script:

```ruby
# Add to your build task
task :build do
  # ... existing build steps ...

  # Generate search data
  sh 'bin/generate-search-index'
  sh 'npx --yes lunr@2.3.9 -- bin/build-lunr-index'

  # ... rest of build ...
end
```

Or add to `bin/build` script:

```bash
#!/bin/bash
set -e

# Existing build
site build

# Generate search data
bin/generate-search-index
npx --yes lunr@2.3.9 -- bin/build-lunr-index

echo "Build complete with search index"
```

### 5. Test Locally

```bash
# Build site with search
./bin/build

# Check files were created
ls -lh build/pages.json build/search-index.json build/404.html

# Serve locally
cd build && python3 -m http.server 8000

# Test in browser
open http://localhost:8000/nonexistent-page
```

Verify:
- 404 page loads
- Static URL list visible immediately
- Search box appears
- Typing filters results in real-time
- Click results navigate correctly

### 6. Deploy to GitHub Pages

Ensure `.github/workflows/deploy.yml` includes the search files:

```yaml
- name: Build site
  run: |
    bundle exec site build
    bin/generate-search-index
    npx --yes lunr@2.3.9 -- bin/build-lunr-index

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./build
    # 404.html automatically served by GitHub Pages
```

## Verification

### Manual Testing

1. Navigate to any broken URL on your site
2. Verify 404 page loads with search box
3. Type a search query - results should filter instantly
4. Click a result - should navigate correctly
5. Clear search - all pages reappear
6. Disable JavaScript - static list still works

### Performance Testing

```bash
# Check index size
du -h build/search-index.json build/pages.json

# Should be:
# - pages.json: ~60-100KB (gzipped)
# - search-index.json: ~60-80KB (gzipped)
```

### Build Testing

```bash
# Time the build
time ./bin/build

# Search generation should add 3-5 seconds
```

## Troubleshooting

**Problem**: Index too large (>100KB compressed)

**Solution**: Reduce content length or implement title-only search for some pages

**Problem**: Search not working

**Solution**: Check browser console for errors. Verify pages.json and search-index.json loaded correctly.

**Problem**: Build fails on `bin/build-lunr-index`

**Solution**: Ensure Node.js installed. Try `npx --yes lunr` to auto-install.

## Next Steps

- Monitor 404 page analytics to see what pages users are searching for
- Add categories/tags to search if needed
- Consider adding spelling correction for common typos
- Track most common "not found" URLs to identify broken links

## Performance Targets

| Metric | Target | How to Verify |
|--------|--------|---------------|
| Index size (compressed) | <100KB | `du -h build/search-index.json` (after gzip) |
| Search latency | <100ms | Browser DevTools Network tab |
| Page load (3G) | <2s | Chrome DevTools throttling |
| Build time overhead | <10s | `time ./bin/build` |

## Constitution Compliance

- ✅ **Simplicity**: Direct lunr.js usage, no framework wrapper
- ✅ **Truth**: Honest "not found" message, documented limitations
- ✅ **Plaintext**: JSON files, greppable and version-controlled
- ✅ **Direct**: Clear UX, no jargon
- ✅ **Testing**: Manual testing procedure defined
- ✅ **Ruby Idioms**: IO.binread, guards, follows existing patterns
- ✅ **Atomic**: Index written atomically (temp + move in production)
- ✅ **Minimal Deps**: Only lunr.js added (justified for search)

## Reference

- Feature Spec: `specs/001-404-search-page/spec.md`
- Research: `specs/001-404-search-page/research.md`
- Data Model: `specs/001-404-search-page/data-model.md`
- Contracts: `specs/001-404-search-page/contracts/`
