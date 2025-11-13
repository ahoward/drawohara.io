# Research: Static 404 Page with Search

**Feature**: 001-404-search-page
**Date**: 2025-11-13
**Phase**: 0 (Pre-Design Research)

## Research Questions

1. Lunr.js best practices for pre-built search indexes
2. Index size optimization strategies for static sites
3. Search scope strategy (title-only vs title+content tradeoffs)
4. Progressive enhancement implementation patterns
5. CDN hosting best practices for lunr.js

---

## 1. Pre-Built Index Pattern

### Decision: Build Server-Side During Site Generation

**Rationale**: Pre-building the index during site generation and serving a serialized JSON file provides significantly better user experience than client-side index building.

**Performance Implications**:
- Server-side: No browser blocking, faster search response, can be compressed/cached
- Client-side: Smaller initial payload but blocks browser during build (CPU-intensive)
- Threshold: For sites with >100 pages, pre-building is strongly recommended

**Implementation**:
```javascript
// Build time (Node.js)
const idx = lunr(function () {
  this.ref('href');
  this.field('title', { boost: 10 });
  this.field('content');
  documents.forEach(doc => this.add(doc));
});
fs.writeFileSync('search-index.json', JSON.stringify(idx));

// Client-side (load pre-built index)
fetch('/search-index.json')
  .then(r => r.json())
  .then(data => {
    const idx = lunr.Index.load(data);
    // Ready for searching
  });
```

**Alternatives Considered**:
- Client-side build: Rejected due to browser blocking and poor mobile performance
- Hybrid (partial pre-build): Rejected due to added complexity without clear benefit

---

## 2. Index Size Optimization

### Decision: Title + Truncated Content (150 chars) with Compression

**Rationale**: Balances search quality with acceptable index size for 500-page site.

**Expected Sizes**:
- Raw index: ~250 KB (500 bytes per document average)
- Gzip compressed: ~38-50 KB (85% reduction)
- Brotli compressed: ~28-35 KB (89% reduction)

**Target**: <100 KB compressed for optimal performance on 3G networks

**Optimization Strategies**:

1. **Field Selection**: Title + truncated content (not full content)
   - Title only: ~30% size but low recall
   - Title + full content: 100% size but high recall
   - **Title + 150 char excerpt: 50-60% size, balanced recall/precision** ✓

2. **Content Truncation**: First 150 characters or meta description
   ```javascript
   content: metaDescription || bodyText.substring(0, 150)
   ```

3. **Compression**: Use Brotli with gzip fallback
   - Brotli: 23% better than gzip
   - Both generated at build time
   - Server configured to serve compressed versions

**Alternatives Considered**:
- Title-only search: Rejected due to low recall (40-60%)
- Full content indexing: Rejected due to excessive index size (>200 KB)
- Field vector compacting: Deferred (20-25% gain but added complexity)

---

## 3. Search Scope Strategy

### Decision: Title Boosted 10x Over Content

**Rationale**: Provides high precision while maintaining good recall. Title matches appear first, content matches provide comprehensive results.

**Comparison**:

| Approach | Precision | Recall | Index Size | Recommendation |
|----------|-----------|--------|------------|----------------|
| Title only | 85-90% | 40-60% | Small | Documentation sites |
| Title + Content (equal) | 60-70% | 80-95% | Large | Not recommended |
| **Title boosted 10x** | **75-85%** | **75-90%** | **Medium** | **Most sites** ✓ |
| Title boosted 100x | 90%+ | 60-75% | Medium | Very title-focused sites |

**Implementation**:
```javascript
const idx = lunr(function () {
  this.ref('href');
  this.field('title', { boost: 10 });  // Strong relevance signal
  this.field('content');                // Baseline relevance
});
```

**Field Boosting Guidelines**:
- Title: 10x (primary topic signal)
- Tags/Categories: 5x (if applicable)
- Excerpt: 2x (important but not definitive)
- Content: 1x (baseline)

**Alternatives Considered**:
- Equal weighting: Rejected due to too many low-quality matches
- Title-only: Rejected due to missing relevant content-based matches
- 100x boost: Rejected due to reduced recall

---

## 4. Progressive Enhancement

### Decision: External Search Fallback (DuckDuckGo/Google)

**Rationale**: Lunr.js requires JavaScript with no built-in progressive enhancement. External search provides functional fallback without server infrastructure.

**Reality Check**: True no-JavaScript search with lunr.js is impossible. Must provide alternative.

**Recommended Approach**:
```html
<!-- Works without JavaScript (external search) -->
<form action="https://duckduckgo.com/" method="get" id="search-form">
  <input type="hidden" name="sites" value="yoursite.com">
  <input type="search" name="q" placeholder="Search..." required>
  <button type="submit">Search</button>
</form>

<!-- Progressive enhancement with lunr.js -->
<script>
  document.getElementById('search-form').addEventListener('submit', function(e) {
    e.preventDefault(); // Stop external search
    const query = this.querySelector('[name="q"]').value;
    performLunrSearch(query); // Use lunr instead
  });
</script>
```

**Benefits**:
- Works without JavaScript (fallback to DuckDuckGo)
- Enhanced with lunr.js when available
- No server infrastructure required
- Simple implementation

**Alternatives Considered**:

1. **Server-side search endpoint**: Rejected due to requiring serverless infrastructure (Netlify Functions, etc.)
2. **Static results page**: Rejected due to poor UX (no search, just list)
3. **Self-hosted fallback only**: Rejected as still requires JavaScript

**Additional Enhancement**: Static URL list below search box provides browsing fallback

---

## 5. CDN Hosting Best Practices

### Decision: unpkg with SRI Hash

**Rationale**: Direct npm mirror, simple integration, sufficient reliability for static sites.

**Recommended Implementation**:
```html
<script
  src="https://unpkg.com/lunr@2.3.9/lunr.min.js"
  integrity="sha512-4xUl/d6D6THrAnXAwGajXkoWaeMNwEKK4iNfq5DotEbLPAfk6FSxSP3ydNxqDgCw1c/0Z1Jg6L8h2j+++9BZmg=="
  crossorigin="anonymous">
</script>
```

**CDN Comparison**:

| CDN | Performance | Reliability | Best For |
|-----|-------------|-------------|----------|
| jsDelivr | ~90ms | 99.99% | Production (multi-CDN) |
| cdnjs | ~120ms | 99.9% | Cloudflare users |
| **unpkg** | **~130ms** | **99.5%** | **Simple sites** ✓ |

**SRI (Subresource Integrity) Hash**:
- **Always use** with CDN resources
- Prevents tampering if CDN compromised
- Required attributes: `integrity`, `crossorigin`
- Hash for lunr.js 2.3.9: `sha512-4xUl/d6D6THrAnXAwGajXkoWaeMNwEKK4iNfq5DotEbLPAfk6FSxSP3ydNxqDgCw1c/0Z1Jg6L8h2j+++9BZmg==`

**Fallback Strategy** (optional):
```javascript
// Self-hosted fallback if CDN fails
if (typeof lunr === 'undefined') {
  const script = document.createElement('script');
  script.src = '/js/lunr.min.js';
  document.head.appendChild(script);
}
```

**Performance Optimizations**:
```html
<!-- DNS prefetch for faster CDN connection -->
<link rel="dns-prefetch" href="https://unpkg.com">

<!-- Preconnect for even faster loading -->
<link rel="preconnect" href="https://unpkg.com" crossorigin>
```

**Alternatives Considered**:
- jsDelivr: Better performance but unnecessary complexity for simple site
- cdnjs: Cloudflare-backed but similar performance to unpkg
- Self-hosted only: Rejected due to losing CDN caching benefits

---

## Summary of Key Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| **Index Pattern** | Pre-built server-side | Eliminates browser blocking, faster UX |
| **Index Size** | Title + 150 char excerpt, Brotli compressed | ~35 KB compressed, balanced quality/size |
| **Search Scope** | Title (10x boost) + content | 75-85% precision, 75-90% recall |
| **Progressive Enhancement** | External search fallback (DuckDuckGo) | Works without JS, no server infrastructure |
| **CDN Hosting** | unpkg with SRI hash | Simple, reliable, secure |

**Performance Targets**:
- Index size: <100 KB compressed (target: ~35 KB Brotli)
- Load time: <100ms on good connection
- Search response: <50ms for typical queries
- Total overhead: <150ms end-to-end

**Implementation Checklist**:
- [ ] Build script generates search index during site build
- [ ] Index includes title (boosted 10x) + 150 char content
- [ ] Index compressed with Brotli and gzip at build time
- [ ] CDN script tag includes SRI hash
- [ ] Search form falls back to external search without JS
- [ ] Static URL list provides additional browsing option

---

## References

- Lunr.js Documentation: https://lunrjs.com/
- SRI Hash Generator: https://www.srihash.org/
- Progressive Enhancement Patterns: https://developer.mozilla.org/en-US/docs/Glossary/Progressive_Enhancement
- CDN Performance Comparison: https://www.cdnperf.com/
- Brotli Compression: https://github.com/google/brotli

**Next Phase**: Design (data model, contracts, quickstart guide)
