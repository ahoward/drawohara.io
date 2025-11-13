# Data Model: Static 404 Page with Search

**Feature**: 001-404-search-page
**Date**: 2025-11-13
**Phase**: 1 (Design)

## Overview

This feature uses two primary data structures: **PageDocument** (source data for each page) and **SearchIndex** (lunr.js pre-built index). Both are static JSON files generated at build time.

---

## Entities

### PageDocument

Represents a single site page with searchable fields.

**Purpose**: Source data for building the search index and displaying search results.

**Storage**: `/build/pages.json` (JSON array)

**Lifecycle**: Generated during site build from HTML files

**Schema**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `title` | string | Yes | Page title from `<title>` or `<h1>` tag | Max 200 chars |
| `href` | string | Yes | Relative URL path | Must start with `/` |
| `content` | string | No | First 150 chars of page content or meta description | Max 150 chars |

**Example**:
```json
{
  "title": "About Us - Our Mission and Team",
  "href": "/about/",
  "content": "We are a team of developers building amazing things. Our mission is to create simple, powerful tools for everyone."
}
```

**Validation Rules**:
- `title`: Must not be empty, trimmed of whitespace
- `href`: Must be valid relative URL starting with `/`
- `content`: Optional but recommended for search quality

**Extraction Strategy**:
1. Title: `<title>` tag → `<h1>` tag → filename as fallback
2. Content: `<meta name="description">` → `<meta property="og:description">` → first `<p>` text
3. Href: Relative path from build directory (e.g., `build/about/index.html` → `/about/`)

---

### SearchIndex

Pre-built lunr.js search index for client-side querying.

**Purpose**: Enables fast client-side full-text search without rebuilding index in browser.

**Storage**: `/build/search-index.json` (JSON object)

**Lifecycle**: Generated from `pages.json` using lunr.js at build time

**Schema**: Lunr.js serialized index format (opaque structure)

**Key Fields** (from lunr.js internals):

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Lunr.js version used to build index |
| `fields` | array | Searchable field names (`["title", "content"]`) |
| `fieldVectors` | object | Inverted index mapping documents to field vectors |
| `invertedIndex` | object | Term frequency data for fast searching |
| `pipeline` | array | Text processing pipeline configuration |

**Example** (abbreviated):
```json
{
  "version": "2.3.9",
  "fields": ["title", "content"],
  "fieldVectors": [...],
  "invertedIndex": {
    "about": {"_index": 0, "df": 3, ...},
    "mission": {"_index": 1, "df": 1, ...}
  },
  "pipeline": ["stemmer", "stopWordFilter"]
}
```

**Build Configuration**:
```javascript
lunr(function () {
  this.ref('href');                     // Document ID = href
  this.field('title', { boost: 10 });   // Title weighted 10x
  this.field('content');                // Content baseline weight
  
  pages.forEach(page => this.add(page));
});
```

**Usage**:
```javascript
// Load pre-built index
const idx = lunr.Index.load(searchIndexJson);

// Search
const results = idx.search('about mission');
// Returns: [{ ref: '/about/', score: 1.234, matchData: {...} }, ...]
```

**Constraints**:
- Target size: <100 KB compressed (gzip or Brotli)
- Must be compatible with lunr.js 2.3.9
- Generated atomically (temp file → move to final location)

---

## Data Flow

```
┌─────────────────┐
│  HTML Files     │
│ (build/**/*.html)│
└────────┬────────┘
         │
         │ (Ruby script: bin/generate-search-index)
         ▼
┌─────────────────┐
│  pages.json     │ ◄── PageDocument[]
│ (build/)        │
└────────┬────────┘
         │
         │ (Node.js script: bin/build-lunr-index)
         ▼
┌─────────────────┐
│search-index.json│ ◄── SearchIndex
│ (build/)        │
└────────┬────────┘
         │
         │ (Client-side: 404.html JavaScript)
         ▼
┌─────────────────┐
│ Search Results  │
│ (in-browser)    │
└─────────────────┘
```

**Build Process**:
1. Site build generates HTML files (`build/**/*.html`)
2. `bin/generate-search-index` extracts PageDocument data → `pages.json`
3. `bin/build-lunr-index` builds lunr.js index → `search-index.json`
4. Both JSON files deployed with 404.html
5. Client loads both files and performs search

---

## State Transitions

### PageDocument

**States**: 
- Created (extracted from HTML)
- Serialized (written to pages.json)
- Loaded (by index builder)

**Transitions**:
```
[HTML File] → [Extract] → [PageDocument] → [Serialize] → [pages.json]
```

**Invariants**:
- Title must never be empty (use filename fallback)
- Href must be unique across all pages
- Content truncated to exactly 150 chars if longer

### SearchIndex

**States**:
- Building (lunr.js processing pages)
- Serialized (written to search-index.json)
- Loaded (by client)
- Queried (search operations)

**Transitions**:
```
[pages.json] → [Build Index] → [SearchIndex] → [Serialize] → [search-index.json]
             → [Load in Browser] → [Search] → [Results]
```

**Invariants**:
- Index must be valid lunr.js format
- Version field must match deployed lunr.js version
- All refs must correspond to valid hrefs in pages.json

---

## Relationships

```
PageDocument 1──N→ SearchIndex
  ↑
  │ references
  ↓
SearchResult (client-side, ephemeral)
```

**PageDocument → SearchIndex**:
- Each PageDocument contributes to SearchIndex
- SearchIndex.invertedIndex references PageDocument.href as `ref`
- One-way relationship (SearchIndex doesn't modify PageDocument)

**SearchIndex → SearchResult**:
- Search query → lunr.js → SearchResult[]
- Each SearchResult.ref maps back to PageDocument.href
- Client must join results with pages.json to get title/content

**Example Join**:
```javascript
const results = searchIdx.search('about');
// results = [{ ref: '/about/', score: 1.5 }]

const pageData = pages.find(p => p.href === results[0].ref);
// pageData = { title: 'About Us', href: '/about/', content: '...' }
```

---

## Data Volumes

**Assumptions** (from spec):
- Site has ~500 pages
- Average title length: 40 chars
- Average content length: 150 chars (truncated)
- Average href length: 20 chars

**Expected Sizes**:

| Data | Count | Size per Item | Total Size |
|------|-------|---------------|------------|
| PageDocument | 500 | ~210 bytes | ~105 KB |
| SearchIndex (raw) | 1 | ~250 KB | ~250 KB |
| SearchIndex (gzip) | 1 | ~50 KB | ~50 KB |
| SearchIndex (Brotli) | 1 | ~35 KB | ~35 KB |

**Performance Targets**:
- `pages.json`: <150 KB (raw), <100 KB (compressed)
- `search-index.json`: <250 KB (raw), <100 KB (compressed)
- Combined transfer: <200 KB (compressed)
- Load time on 3G: <2 seconds

---

## Validation

### PageDocument Validation

```ruby
# During extraction (bin/generate-search-index)
def valid_page_document?(doc)
  return false if doc[:title].to_s.strip.empty?
  return false unless doc[:href].to_s.start_with?('/')
  return false if doc[:content] && doc[:content].length > 150
  true
end
```

### SearchIndex Validation

```javascript
// During build (bin/build-lunr-index)
function validateSearchIndex(idx) {
  if (!idx.version || !idx.fields || !idx.invertedIndex) {
    throw new Error('Invalid lunr.js index structure');
  }
  if (idx.version !== '2.3.9') {
    console.warn(`Index version ${idx.version} may not match deployed lunr.js`);
  }
}
```

---

## Performance Considerations

**Indexing** (build time):
- 500 pages × ~50ms per page = ~25 seconds extraction
- Lunr.js index build: ~3-5 seconds
- Total build overhead: ~30 seconds

**Searching** (client-side):
- Index load: ~100-200ms (network + parse)
- Search query: <50ms (typical)
- Result rendering: <10ms
- Total search response: <300ms from first keystroke

**Memory Usage** (client-side):
- pages.json: ~100 KB in memory
- search-index.json: ~250 KB in memory (before decompression)
- Total: ~350 KB JavaScript heap

---

## Future Considerations

**Potential Enhancements** (out of scope for v1):
- Tag/category fields for faceted search
- Date fields for sorting by recency
- Incremental index updates (add/remove pages without full rebuild)
- Multi-language support with lunr-languages plugin

**Scaling Beyond 500 Pages**:
- Consider elasticlunr.js (50% smaller indexes)
- Implement field vector compacting (20-25% size reduction)
- Switch to title-only search for less critical content
- Consider pagination of static URL list

---

## References

- Lunr.js Index Format: https://lunrjs.com/guides/index_prebuilding.html
- Search Index Serialization: https://lunrjs.com/docs/lunr.Index.html#load
- JSON Schema (for contracts): ../contracts/pages-api.json, ../contracts/search-index-api.json
