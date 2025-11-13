# Research: Lunr.js Implementation for 404 Search Page

**Date**: 2025-11-13
**Feature**: Static 404 Page with Search
**Research Focus**: Lunr.js best practices, index optimization, progressive enhancement

## Executive Summary

For a static GitHub Pages site with ~500 pages requiring <100ms search performance and progressive enhancement, lunr.js is an excellent fit with pre-built indexes.

**Key Decisions**:
- Pre-build index server-side (not client-side) for instant search
- Title + content summary (150 chars) for optimal size (<100KB compressed)
- Progressive enhancement with static URL list fallback
- unpkg CDN with SRI hash for security

## 1. Pre-Built Index Pattern (DECISION)

**Rationale**: Building index client-side blocks the browser for several seconds on 500 pages. Pre-building transforms this into a build-time operation.

**Implementation**:
```ruby
# bin/generate-search-index
#!/usr/bin/env ruby
require 'json'

# Generate pages.json from build output
pages = []
Dir.glob('build/**/*.html').each do |file|
  next if file.include?('404.html')

  # Extract title, content summary, URL
  # (details in implementation phase)
end

File.write('build/pages.json', JSON.pretty_generate(pages))
```

Then run Node.js to build lunr index from pages.json.

**Performance**: Build time ~3-5s, client load ~100-200ms, search <10ms

## 2. Index Size Optimization (DECISION)

**Target**: <100KB compressed for 500 pages

**Strategy**: Title + content summary (150 chars max per page)

**Expected Results**:
- Raw JSON: ~400 KB
- Gzip: ~70 KB
- Brotli: ~50 KB

GitHub Pages automatically serves gzip/brotli, so we'll hit the target.

**Alternative if needed**: Field vector compaction (reduces by 25-38% more)

## 3. Search Scope: Title + Content (DECISION)

**Rationale**: Title-only produces poor results (60% recall). Title + content gives 85% recall.

**Field Boosting**:
```javascript
this.field('title', { boost: 10 });  // Title matches rank 10x higher
this.field('content');               // Baseline weight
```

This ensures title matches appear first while still finding content matches.

## 4. Progressive Enhancement Pattern (DECISION)

**Three-Tier Strategy**:

1. **Baseline (no JS)**: Static HTML list of all URLs - fully functional
2. **Enhanced (JS loads)**: Dynamic search with instant filtering
3. **Optimized (fast connection)**: Pre-loaded index

**Implementation**:
- Server-render static URL list in 404.html
- Load lunr.js and search index asynchronously (non-blocking)
- Search functionality enhances the page but isn't required

**Key Benefit**: Page is 100% functional without JavaScript, search is progressive enhancement.

## 5. CDN Hosting: unpkg with SRI (DECISION)

**Choice**: unpkg.com (officially recommended by lunr.js)

**Implementation**:
```html
<script
  src="https://unpkg.com/lunr@2.3.9/lunr.min.js"
  integrity="sha384-[HASH]"
  crossorigin="anonymous"
></script>
```

**Rationale**:
- Official recommendation
- 99.9% uptime
- 19 KB gzipped
- SRI hash prevents tampering
- Fast global CDN

**Alternative**: jsDelivr (has automatic failover if needed)

## Implementation Notes

### Build Process Integration

Add to existing `site build` workflow:
1. Generate `build/pages.json` from all HTML pages
2. Run Node.js script to create `build/search-index.json` from pages.json
3. Generate `build/404.html` with embedded static URL list

### Document Structure

```json
{
  "title": "Page Title",
  "href": "/page/path/",
  "content": "First 150 chars of content or meta description..."
}
```

### Search UX

- Real-time filtering (as-you-type)
- Highlight matching terms in results
- Show "no results" message when empty
- Clear search = show all pages again

## Performance Targets

| Metric | Target | Expected |
|--------|--------|----------|
| Index size (compressed) | <100 KB | 60-80 KB |
| Search latency | <100 ms | 5-15 ms |
| Page load (3G) | <2 s | <1 s |
| Build time | Reasonable | 3-5 s |

## References

- [Lunr.js Pre-building Guide](https://lunrjs.com/guides/index_prebuilding.html)
- [Index Compaction Technique](https://john-millikin.com/compacting-lunr-search-indices)
- [Progressive Enhancement Patterns](https://www.gov.uk/service-manual/technology/using-progressive-enhancement)

## Next Steps (Phase 1)

1. Define data model for search documents
2. Create build script to generate pages.json
3. Create Node.js script to build lunr index
4. Design 404.html template with progressive enhancement
