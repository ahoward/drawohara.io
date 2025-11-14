# Debugging 404 Search Page

## Issues Reported

1. ✅ **FIXED**: All links showing "drawohara" as title
   - **Fix**: Updated bin/generate-search-index to use first paragraph text
   - **Result**: Now shows meaningful titles like "this is the part i hate. writing about myself."

2. ❓ **TO DEBUG**: Search box not filtering

## How to Debug Search Issue

### Step 1: Check Browser Console

Open your preview server and navigate to: `http://your-preview-server/404.html`

Open browser console (F12) and look for:

1. **JavaScript errors** - any red errors?
2. **Network errors** - check Network tab for failed requests to:
   - `/pages.json` (should return 200)
   - `/search-index.json` (should return 200)  
   - `https://unpkg.com/lunr@2.3.9/lunr.min.js` (should return 200)

### Step 2: Check Console Messages

You should see:
- `Search ready` (if everything loaded)
- OR `Search unavailable (page list still works)` (if something failed)

### Step 3: Test Search Manually

In browser console, type:
```javascript
// Check if lunr loaded
typeof lunr

// Check if data loaded
console.log(pagesData.length)  // Should be 461
console.log(searchIdx)           // Should be an object

// Try manual search
searchIdx.search('about')       // Should return results
```

### Step 4: Common Issues

**Issue**: `pagesData` or `searchIdx` is undefined
- **Cause**: JSON files didn't load
- **Fix**: Check paths - are you serving from root or subdirectory?

**Issue**: lunr is undefined
- **Cause**: CDN blocked or script didn't load
- **Fix**: Check Network tab, try self-hosting lunr.js

**Issue**: Search works in console but not in UI
- **Cause**: Event listener not attached
- **Check**: Type in search box, does status change?

### Step 5: Use Test Page

Navigate to `http://your-preview-server/test-404.html`

This will run automated tests and show results in console:
- ✓ lunr.js loaded
- ✓ pages.json loaded (461 pages)  
- ✓ search-index.json loaded
- ✓ Search test found X results

## Quick Fixes

### If JSON files return 404

Your server might not be serving them from root. Check:
```bash
curl http://localhost:YOUR_PORT/pages.json
curl http://localhost:YOUR_PORT/search-index.json
```

If they're 404, the files might be in wrong location or server config issue.

### If Search Works in Console But Not UI

Check if event listener is attached:
```javascript
// In console
searchInput  // Should be the input element
searchInput.oninput  // Should show function or null
```

If null, the Promise.all might have failed silently.

### If Everything Loads But No Results

Check index compatibility:
```javascript
// In console  
searchIdx.search('*')  // Try wildcard
pagesData[0]           // Check page format
```

## Files Generated

- `build/404.html` (43 KB) - The 404 page
- `build/pages.json` (100 KB, 22 KB gzipped) - Page metadata
- `build/search-index.json` (480 KB, 54 KB gzipped) - Search index
- `build/test-404.html` - Test page for debugging

## Expected Behavior

1. Navigate to non-existent URL (or /404.html directly)
2. Page shows static list immediately (no JS required)
3. After ~100-200ms, "Search ready" appears  
4. Type in search box
5. Results filter instantly as you type
6. Click result → navigate to page

## Report Back

If still not working, check browser console and report:
1. Any error messages (red text)
2. Status message shown ("Search ready" vs "Search unavailable")
3. Network tab - do all 3 files load successfully?
4. Console test results from Step 3 above
