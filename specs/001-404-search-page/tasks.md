# Tasks: Static 404 Page with Search

**Input**: Design documents from `/specs/001-404-search-page/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Not requested in specification - omitted from tasks

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md structure:
- `bin/` - Build scripts
- `build/` - Generated static files (404.html, JSON)
- `config/` - Site configuration (existing)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and build tooling setup

- [ ] T001 Install lunr.js for build process via npm: `npm install --save-dev lunr@2.3.9`
- [ ] T002 [P] Verify Ruby nokogiri gem available for HTML parsing (existing dependency)
- [ ] T003 [P] Verify existing build process can be extended for search index generation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create bin/generate-search-index Ruby script to extract page data from build/**/*.html
- [ ] T005 Create bin/build-lunr-index Node.js script to generate search index from pages.json
- [ ] T006 [P] Create build/404.html template with search UI and progressive enhancement
- [ ] T007 Generate build/pages.json by running bin/generate-search-index on existing build output
- [ ] T008 Generate build/search-index.json by running bin/build-lunr-index from pages.json
- [ ] T009 Verify JSON contracts match contracts/pages-api.json and contracts/search-index-api.json

**Checkpoint**: Foundation ready - page data extracted, search index built, 404 page template created

---

## Phase 3: User Story 1 - Find Correct Page via Search (Priority: P1) 🎯 MVP

**Goal**: Visitor can land on 404 page and use real-time search to find their intended page

**Independent Test**: Navigate to any non-existent URL (e.g., /missing-page), type "about" in search box, verify matching pages appear instantly with clickable links

### Implementation for User Story 1

- [ ] T010 [US1] Implement search box input handler in build/404.html to filter results as-you-type
- [ ] T011 [US1] Load lunr.js from unpkg CDN with SRI hash in build/404.html <script> tag
- [ ] T012 [US1] Implement async loading of search-index.json and pages.json in build/404.html
- [ ] T013 [US1] Initialize lunr.Index.load() with fetched search-index.json data
- [ ] T014 [US1] Implement search query handler using searchIndex.search(query)
- [ ] T015 [US1] Map lunr results (ref IDs) back to PageDocument objects from pages.json
- [ ] T016 [US1] Implement displayResults() function to render search results with highlighted matches
- [ ] T017 [US1] Add highlight() function to mark matching terms with <mark> tags
- [ ] T018 [US1] Implement "no results found" message when search returns empty array
- [ ] T019 [US1] Implement clear search behavior (empty query shows all pages)
- [ ] T020 [US1] Add search status indicator ("Search ready", "Loading...")

**Checkpoint**: Search functionality complete - visitor can search and find pages instantly

---

## Phase 4: User Story 2 - Browse Complete Site Map (Priority: P2)

**Goal**: Visitor can browse a complete static list of all site URLs without using search

**Independent Test**: Access any 404 page, scroll down past search box, verify complete list of all site URLs as clickable links

### Implementation for User Story 2

- [ ] T021 [US2] Generate static HTML <ul> list from pages.json during build in build/404.html
- [ ] T022 [US2] Embed all page titles and href values as <li><a> elements in 404.html
- [ ] T023 [US2] Style page list with CSS (list-style: none, padding, borders)
- [ ] T024 [US2] Ensure static list renders immediately (no JavaScript required)
- [ ] T025 [US2] Verify list shows all pages without pagination (500+ entries)
- [ ] T026 [US2] Test that clicking any URL from list navigates correctly

**Checkpoint**: Static URL list complete - visitor can browse all pages even if search fails

---

## Phase 5: User Story 3 - Understand Error with Friendly Message (Priority: P3)

**Goal**: Visitor sees friendly, non-technical error message explaining what happened

**Independent Test**: View any 404 page, read message at top, verify it's simple and friendly (no "404" or HTTP codes prominently displayed)

### Implementation for User Story 3

- [ ] T027 [US3] Write friendly error message in build/404.html <h1> and <p> tags
- [ ] T028 [US3] Ensure message explains "page not found" without technical jargon
- [ ] T029 [US3] Position message above search box for immediate visibility
- [ ] T030 [US3] Add instruction text guiding visitor to search or browse
- [ ] T031 [US3] Style error message with clear typography (no aggressive red/warnings)

**Checkpoint**: Friendly messaging complete - visitor understands situation without confusion

---

## Phase 6: Integration & Build Process

**Purpose**: Integrate 404 page generation into existing site build workflow

- [ ] T032 Add bin/generate-search-index call to existing build process in config/site.rb or bin/build
- [ ] T033 Add bin/build-lunr-index call after pages.json generation
- [ ] T034 Ensure build/404.html, build/pages.json, build/search-index.json are created on every build
- [ ] T035 Verify GitHub Pages will serve 404.html automatically for missing pages
- [ ] T036 [P] Add .gitignore entry for node_modules/ if not already present

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final deployment

- [ ] T037 [P] Verify index size <100KB compressed (gzip/brotli) using `du -h build/search-index.json`
- [ ] T038 [P] Test search performance <100ms using browser DevTools Network tab
- [ ] T039 [P] Test page load <2s on simulated 3G using Chrome DevTools throttling
- [ ] T040 Verify progressive enhancement (disable JavaScript, confirm static list still works)
- [ ] T041 Test with 500+ pages to ensure performance targets met
- [ ] T042 [P] Add SRI hash for lunr.js CDN link: `integrity="sha384-..."`
- [ ] T043 Add error handling for failed lunr.js CDN load with handleLunrLoadError()
- [ ] T044 Verify ARIA attributes for accessibility (aria-label, role="searchbox", etc.)
- [ ] T045 Test keyboard navigation (tab through search, results, links)
- [ ] T046 [P] Update deployment workflow to include search index generation
- [ ] T047 Deploy to GitHub Pages and verify 404.html served correctly
- [ ] T048 Test on real domain (navigate to /nonexistent-page)
- [ ] T049 Validate against quickstart.md manual testing procedure

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - US1 (Search): Can start after Foundational
  - US2 (Browse): Can start after Foundational (parallel with US1)
  - US3 (Message): Can start after Foundational (parallel with US1/US2)
- **Integration (Phase 6)**: Depends on US1, US2, US3 completion
- **Polish (Phase 7)**: Depends on Integration completion

### User Story Dependencies

- **User Story 1 (P1 - Search)**: Independent - requires only Foundational phase
- **User Story 2 (P2 - Browse)**: Independent - can run parallel with US1
- **User Story 3 (P3 - Message)**: Independent - can run parallel with US1/US2

### Within Each User Story

- **US1**: Search box → CDN load → Index loading → Query handler → Results display → Highlighting
- **US2**: Static list generation → Embedded in HTML → CSS styling → Navigation verification
- **US3**: Message writing → Positioning → Styling

### Parallel Opportunities

- Setup tasks (T002, T003) can run in parallel
- Foundational task T006 (404.html template) can run parallel with T004, T005
- **User Stories 1, 2, 3 can ALL run in parallel** after Foundational phase
- Polish tasks (T037, T038, T039, T042, T044, T046) can run in parallel

---

## Parallel Example: User Stories (Phases 3-5)

```bash
# After completing Foundational (Phase 2), launch all user stories in parallel:

# Developer A or Agent A - User Story 1:
Tasks T010-T020: "Implement real-time search functionality"

# Developer B or Agent B - User Story 2:
Tasks T021-T026: "Generate static site map list"

# Developer C or Agent C - User Story 3:
Tasks T027-T031: "Add friendly error messaging"

# All three stories can be completed independently and tested independently
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T009) - CRITICAL BLOCKER
3. Complete Phase 3: User Story 1 (T010-T020) - Search functionality
4. **STOP and VALIDATE**: Navigate to /nonexistent-page, verify search works
5. Deploy MVP with just search (US2 and US3 can wait)

### Incremental Delivery

1. **Foundation** (Setup + Foundational) → Search infrastructure ready
2. **+US1** (Search) → Test independently → Deploy/Demo (MVP!)
3. **+US2** (Browse) → Test independently → Deploy/Demo (enhanced)
4. **+US3** (Message) → Test independently → Deploy/Demo (complete)
5. **+Integration** → Full build process integrated
6. **+Polish** → Production-ready

### Parallel Team Strategy

With multiple developers or agents:

1. **Together**: Complete Setup (Phase 1) + Foundational (Phase 2)
2. **Split after Foundational**:
   - Dev A: User Story 1 (T010-T020) - Search
   - Dev B: User Story 2 (T021-T026) - Browse
   - Dev C: User Story 3 (T027-T031) - Message
3. **Together**: Integration (Phase 6) after all stories complete
4. **Parallel**: Polish tasks (Phase 7)

---

## Task Summary

**Total Tasks**: 49

**Per Phase**:
- Setup: 3 tasks
- Foundational: 6 tasks (BLOCKING)
- User Story 1 (Search): 11 tasks
- User Story 2 (Browse): 6 tasks
- User Story 3 (Message): 5 tasks
- Integration: 5 tasks
- Polish: 13 tasks

**Parallel Opportunities**:
- 16 tasks marked [P] can run in parallel (within their phases)
- All 3 user stories can run in parallel after Foundational phase
- MVP delivery possible after just US1 (20 tasks total)

**Independent Test Criteria**:
- US1: Type search query → see instant results
- US2: Scroll to static list → see all URLs → click works
- US3: Read error message → clear and friendly

**Suggested MVP Scope**: Setup + Foundational + US1 only (20 tasks, ~2-3 hours)

**Format Validation**: ✅ All tasks follow checklist format with task IDs, [P] markers, [Story] labels, and file paths

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each logical group or checkpoint
- Stop at any checkpoint to validate story independently
- Progressive enhancement ensures page works without JavaScript (US2 provides fallback)
- Constitution compliance maintained throughout (simplicity, plaintext, minimal deps)
