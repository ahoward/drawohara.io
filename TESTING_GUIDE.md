# Testing Guide: 404 Search Page

## Pre-Deployment Testing

### Local Testing Setup

1. **Build the site** (with search integration):
   ```bash
   # Run your normal build + search build
   site build  # or your build command
   bin/build-search
   ```

2. **Start local server**:
   ```bash
   cd build
   python3 -m http.server 8000
   ```

3. **Access test URL**:
   ```
   http://localhost:8000/nonexistent-page
   ```

---

## Test Checklist

### T037: Verify Index Size

```bash
# Check uncompressed size
du -h build/search-index.json build/pages.json

# Simulate gzip compression
gzip -c build/search-index.json | wc -c
gzip -c build/pages.json | wc -c

# Target: Combined <100KB compressed
```

**Expected**: 
- pages.json: ~60-100KB (raw), ~15-30KB (gzipped)
- search-index.json: ~60-100KB (raw), ~35-50KB (gzipped)
- **Combined**: <100KB gzipped ✓

---

### T038: Test Search Performance

**Using Browser DevTools**:

1. Open DevTools (F12) → Network tab
2. Navigate to 404 page
3. Type in search box
4. Watch for search-index.json and pages.json load times
5. Observe search result rendering time

**Expected**:
- Initial load: <200ms (network fetch)
- Search query response: <100ms (client-side)
- Result rendering: <50ms

---

### T039: Test Page Load on 3G

**Using Chrome DevTools Throttling**:

1. Open DevTools → Network tab
2. Select "Slow 3G" from throttling dropdown
3. Hard refresh (Ctrl+Shift+R)
4. Measure total page load time

**Expected**:
- Full page load: <2s on Slow 3G
- Static list visible immediately (progressive enhancement)
- Search becomes available after JS loads

---

### T040: Progressive Enhancement ✓

**Test without JavaScript**:

1. Open DevTools → Settings → Preferences
2. Disable JavaScript
3. Reload 404 page
4. Verify:
   - ✓ Friendly error message displays
   - ✓ Static page list displays
   - ✓ All links are clickable
   - ✗ Search box present but non-functional (expected)

**PASS**: Page remains fully usable without JavaScript

---

### T041: Test with 500+ Pages

**Stress Test**:

1. Ensure site has 500+ pages
2. Run full build with search
3. Check:
   - Build completes without errors
   - Index size remains <100KB
   - 404 page loads <2s
   - Search results appear <100ms
   - Static list shows all pages

---

### T042: SRI Hash ✓

**Verify in 404.html**:

```html
<script src="https://unpkg.com/lunr@2.3.9/lunr.min.js" 
        integrity="sha512-4xUl/d6D6THrAnXAwGajXkoWaeMNwEKK4iNfq5DotEbLPAfk6FSxSP3ydNxqDgCw1c/0Z1Jg6L8h2j+++9BZmg=="
        crossorigin="anonymous"></script>
```

**PASS**: SRI hash present and correct

---

### T043: CDN Error Handling ✓

**Test CDN Failure**:

1. Block unpkg.com in browser (DevTools → Network → Block request domain)
2. Reload 404 page
3. Verify:
   - Error caught in console
   - Status message: "Search unavailable (page list still works)"
   - Static list remains functional

**PASS**: Graceful fallback to static list

---

### T044: ARIA Attributes ✓

**Verify Accessibility**:

```html
<input
  type="text"
  id="search"
  placeholder="Search for pages..."
  aria-label="Search site pages"
>
```

**Check**:
- ✓ aria-label on search input
- ✓ Semantic HTML (<h1>, <ul>, <li>)
- ✓ Color contrast meets WCAG AA

**PASS**: Basic accessibility requirements met

---

### T045: Keyboard Navigation

**Test with Keyboard Only**:

1. Navigate to 404 page
2. Press Tab repeatedly
3. Verify:
   - Focus visible on search box
   - Tab through search results
   - Enter key activates links
   - Escape key clears search (if implemented)

**Expected**: Full keyboard navigation support

---

### T046: Deployment Workflow ✓

**Verify GitHub Actions** (`.github/workflows/deploy.yml`):

```yaml
- name: Build site
  run: |
    bundle exec site build
    bin/build-search  # ← Must be present
```

**Check**:
- ✓ Search build integrated into CI/CD
- ✓ All artifacts deployed (404.html, pages.json, search-index.json)

---

### T047-T048: Production Testing

**After deployment to GitHub Pages**:

1. **Navigate to real 404**:
   ```
   https://yourdomain.com/this-does-not-exist
   ```

2. **Verify**:
   - 404 page loads automatically
   - Search box functional
   - Static list displays
   - Search finds results
   - Clicking results navigates correctly

3. **Test scenarios**:
   - Search for existing page title
   - Search for content keywords
   - Try search with no results
   - Clear search and browse list
   - Disable JS and verify static list

---

### T049: Full Manual Test (from quickstart.md)

**Complete Test Procedure**:

1. **Setup**: Deploy to production
2. **Navigate**: Go to broken URL
3. **Test Search**:
   - Type "about" → verify results appear
   - Click result → verify navigation works
   - Type gibberish → verify "no results" message
   - Clear search → verify all pages reappear
4. **Test Browse**:
   - Scroll down
   - Verify all site pages listed
   - Click random links → verify navigation
5. **Test Message**:
   - Read error message
   - Verify friendly, non-technical language
6. **Test Without JS**:
   - Disable JavaScript
   - Verify static list still works
   - Verify links still navigate

**Success Criteria**: All tests pass

---

## Performance Benchmarks

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Index size (compressed) | <100KB | `gzip -c build/*.json \| wc -c` |
| Search latency | <100ms | DevTools Network tab |
| Page load (3G) | <2s | DevTools throttling |
| Build overhead | <10s | `time bin/build-search` |

---

## Known Limitations

- Search requires JavaScript (static list fallback)
- Index limited to ~1000 pages (design constraint)
- No spelling correction or fuzzy matching
- No search query history or autocomplete

---

## Troubleshooting

**Search not working**:
- Check browser console for errors
- Verify pages.json and search-index.json loaded (Network tab)
- Verify lunr.js CDN accessible

**Index too large**:
- Reduce content excerpt length in bin/generate-search-index
- Consider title-only search for some pages

**Build fails**:
- Verify nokogiri gem installed (Ruby)
- Verify Node.js available for lunr
- Check bin/ scripts are executable (chmod +x)
