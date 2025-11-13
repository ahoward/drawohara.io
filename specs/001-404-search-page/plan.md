# Implementation Plan: Static 404 Page with Search

**Branch**: `001-404-search-page` | **Date**: 2025-11-13 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-404-search-page/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Create a static 404.html page for GitHub Pages that helps visitors find content through client-side search and a complete site map. Uses lunr.js for full-text search across page titles and content, with progressive enhancement to work without JavaScript.

## Technical Context

**Language/Version**: Ruby 3.3+ (for build process), vanilla JavaScript (for client-side search)
**Primary Dependencies**: Existing site build system (ro), Lunr.js (client-side), Kramdown (markdown processing)
**Storage**: Static JSON search index generated at build time
**Testing**: Manual testing on GitHub Pages, build verification
**Target Platform**: GitHub Pages (static hosting), modern browsers with progressive enhancement
**Project Type**: Single static page (404.html) + build-time index generation
**Performance Goals**: Search results <100ms, page load <2s on 3G, index size <100KB for 500 pages
**Constraints**: Static-only (no server-side processing), GitHub Pages compatibility, <100KB page size
**Scale/Scope**: Support 500+ site pages, ~50 lines HTML/CSS/JS, single page implementation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✓ I. Simplicity Over Cleverness
- Static HTML page with minimal JavaScript
- Direct lunr.js integration (no framework wrapper)
- Progressive enhancement (works without JS)
- No clever abstractions - straightforward search implementation

### ✓ II. Truth Over Embellishment
- Honest "page not found" messaging
- No defensive coding for imaginary edge cases
- Document limitations (requires build process, JS for search)

### ✓ III. Plaintext Supremacy
- Search index as JSON (plaintext, greppable)
- Documentation in markdown
- No binary formats or proprietary lock-in

### ✓ IV. Direct Communication
- Simple, friendly error message (no corporate speak)
- Clear user interface with search box and URL list
- Inline comments explain WHY decisions were made

### ✓ V. Test-First Discipline
- Manual testing plan (navigate to missing URL, verify search works)
- Verification: build process generates valid search index
- Integration test: search results match expectations

### ✓ VI. Ruby Idioms
- Use IO.binread for reading page content during index generation
- Follow existing site.rb patterns for integration
- Guards and early returns in build script

### ✓ VII. Atomic Operations
- Search index written atomically (temp file + move)
- Build process uses existing atomic patterns from site

### ✓ VIII. Minimal Dependencies
- Lunr.js: justified for client-side full-text search (CDN, no build step)
- No additional gems beyond existing site dependencies
- Leverages existing ro build system

**GATE STATUS**: ✅ PASS - All principles satisfied, no violations to justify

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
build/
├── 404.html                    # Generated 404 page (deployed to GitHub Pages)
└── search-index.json           # Generated search index

bin/
└── generate-search-index       # Build script to create search index

public/
└── 404.html.erb                # 404 page template (optional if using ERB)

config/
└── site.rb                     # Existing build config (integrate 404 generation)
```

**Structure Decision**: Minimal addition to existing site structure. The 404.html page is generated during the existing site build process. A new bin script creates the search index JSON from all built pages. No new directories needed - integrates with current ro-based static site generator.

## Complexity Tracking

N/A - No constitution violations. All principles satisfied.

## Phase 0: Research ✅ COMPLETE

Generated `research.md` with findings on:
- Pre-built index pattern (server-side generation)
- Index size optimization (title + 150 char summary)
- Search scope strategy (title boost 10x, content baseline)
- Progressive enhancement implementation
- CDN hosting (unpkg with SRI)

**Key Decisions**:
- Use lunr.js with pre-built indexes (<100KB compressed target)
- Progressive enhancement (static HTML list fallback)
- Build-time index generation (not client-side)

## Phase 1: Design & Contracts ✅ COMPLETE

**Artifacts Created**:
- `data-model.md`: PageDocument and SearchIndex entities
- `contracts/pages-api.json`: Static JSON contract for page data
- `contracts/search-index-api.json`: Lunr.js index format contract
- `quickstart.md`: Step-by-step implementation guide
- `CLAUDE.md`: Updated agent context with Ruby 3.3+, JavaScript, Lunr.js

**Data Model**:
- PageDocument: title, href, content (150 chars max)
- SearchIndex: Pre-built lunr.Index serialization
- Build-time extraction from HTML files
- Client-side loading and querying

**Implementation Approach**:
1. Extract page data (Ruby script: bin/generate-search-index)
2. Build lunr index (Node.js script: bin/build-lunr-index)
3. Generate 404.html with progressive enhancement
4. Integrate into existing ro build process
5. Deploy to GitHub Pages (automatic 404 serving)

## Constitution Re-Check (Post-Design)

### ✓ All Principles Still Satisfied

No changes from initial check. Implementation approach maintains:
- Simplicity (direct lunr.js, no abstractions)
- Truth (honest messaging, documented limits)
- Plaintext (JSON files, markdown docs)
- Direct communication (clear UX)
- Testing (manual test plan in quickstart)
- Ruby idioms (IO.binread, guards)
- Atomic operations (temp + move for index)
- Minimal dependencies (only lunr.js added)

**GATE STATUS**: ✅ PASS - Ready for implementation (Phase 2)

## Next Steps

1. Run `/speckit.tasks` to generate implementation tasks
2. Follow quickstart.md for step-by-step implementation
3. Verify constitution compliance during implementation
4. Test with manual procedure from quickstart
5. Deploy to GitHub Pages
