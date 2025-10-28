# Site Redesign Plan: Stripped Down & Hacker-esc

### TL;DR

> kill the framework. kill the tracking. write html. ship it.

Strip down to bare HTML + minimal CSS. Information architecture based on terminal/hacker aesthetic. No frameworks, no tracking, no BS.

---

## Current State Analysis

### What You Have

**Visual:**
- Pico CSS framework (classless)
- Turbo for SPA navigation
- Already fighting frameworks with "anti-pico", "anti-turbo" CSS
- Light/dark mode via Pico
- Google Analytics
- Multi-language support (6 languages)

**Information Architecture:**
- Home page with casual tone
- Navigation hidden in content and footer "goto"
- Pages: /, /about, /contact, /cv, /disco, /jess, /now, /nerd, /io
- Random quotes in footer
- Email-based feedback (heart/hate links)

**The Problem:**
You're already writing CSS to fight Pico. You're disabling Turbo features. You're using a classless framework but... why use a framework at all?

---

## Philosophy Alignment

### From Your Guides

**CODE.md:**
- Simple beats clever
- Stdlib is underrated, frameworks are overrated
- Minimal dependencies
- Direct and readable

**WRITING.md:**
- Direct, no BS
- Short paragraphs
- Get to the point
- No corporate speak

**PHOTOGRAPHY.md:**
- Natural over processed
- Truth over beauty
- Minimal editing
- Functional over fancy

**Translation to Web:**
- Raw HTML over framework
- Plain CSS over preprocessors
- Static over dynamic (when possible)
- Fast over fancy
- Privacy over analytics

---

## The Vision

### Hacker Aesthetic

**Visual Inspiration:**
- Early web (but not ugly)
- Terminal UI
- Monospace fonts for code
- Brutalist simplicity
- motherfuckingwebsite.com meets better-motherfuckingwebsite.com
- Text-first, minimal graphics
- Fast as hell

**Information Architecture:**
- Command-line inspired navigation
- File-system metaphor
- Direct paths, no mystery meat navigation
- Everything one or two clicks away
- No hiding functionality
- Transparent structure

---

## Part 1: Visual Redesign

### Kill the Framework

**Remove:**
```erb
<!-- NO MORE -->
<link href="pico.css">
<script src="turbo.js">
```

**Replace with:**
```html
<!-- YES -->
<style>
  /* your CSS, < 50 lines */
</style>
```

### Minimal CSS

**Base styles (all you need):**

```css
/* reset */
* { margin: 0; padding: 0; box-sizing: border-box; }

/* layout */
body {
  max-width: 42rem;
  margin: 2rem auto;
  padding: 0 1rem;
  font-family: monospace;
  font-size: 16px;
  line-height: 1.6;
  color: #333;
  background: #fff;
}

/* typography */
h1, h2, h3 { margin: 1.5rem 0 0.5rem; }
p { margin: 0.5rem 0; }
a { color: #0066cc; }
a:visited { color: #551a8b; }
code, pre {
  font-family: monospace;
  background: #f5f5f5;
  padding: 0.1em 0.3em;
}

/* dark mode */
@media (prefers-color-scheme: dark) {
  body {
    color: #ddd;
    background: #111;
  }
  a { color: #58a6ff; }
  a:visited { color: #a371f7; }
  code, pre { background: #222; }
}
```

**That's it. Maybe 40 lines total.**

### Typography

**Fonts:**
- System monospace stack for everything
- No web fonts, no loading
- Terminal aesthetic
- Fast and free

**Stack:**
```css
font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, Courier, monospace;
```

### Colors

**Light mode:**
- Background: `#fff` (white)
- Text: `#333` (near black)
- Links: `#0066cc` (blue)
- Code: `#f5f5f5` (light gray bg)

**Dark mode:**
- Background: `#111` (near black)
- Text: `#ddd` (light gray)
- Links: `#58a6ff` (GitHub blue)
- Code: `#222` (dark gray bg)

**No gradients. No shadows. No animations. Terminal colors only.**

### Layout

**Single column:**
```css
body {
  max-width: 42rem;  /* ~80 chars, terminal width */
  margin: 2rem auto;
  padding: 0 1rem;
}
```

**No grid. No flex (unless needed). Just center it and ship.**

### Navigation

**Terminal-style header:**

```
$ cd /home/drawohara
$ ls
about  contact  cv  disco  io  jess  nerd  now

$ cat README.md
[content here]

$ _
```

**Implementation:**
```html
<header>
  <pre>
$ cd /home/drawohara
$ ls -la
drwxr-xr-x <a href="/about">about</a>
drwxr-xr-x <a href="/contact">contact</a>
drwxr-xr-x <a href="/cv">cv</a>
drwxr-xr-x <a href="/disco">disco</a>
drwxr-xr-x <a href="/io">io</a>
drwxr-xr-x <a href="/jess">jess</a>
drwxr-xr-x <a href="/nerd">nerd</a>
drwxr-xr-x <a href="/now">now</a>

$ cat README.md
  </pre>
</header>
```

**Or simpler:**
```
@drawohara :: [ about | contact | cv | disco | io | nerd | now ]
---
```

**Even simpler (current approach is fine):**
```
@drawohara
---
```

**Keep the simplest. Navigation in content is fine.**

---

## Part 2: Information Architecture

### Current Structure

```
/           → home
/about      → about me
/contact    → contact
/cv         → resume
/disco      → disco project
/io         → writing
/jess       → jess
/nerd       → tech writing
/now        → what now
```

**This is good. Keep it.**

### Improvements

#### 1. Make Navigation Explicit

**Current:** Navigation hidden, discovered through content
**Proposed:** Keep it hidden if you want, but make it discoverable

**Option A: Terminal metaphor**
```
$ ls
about contact cv disco io jess nerd now

$ whoami
[content]
```

**Option B: Traditional (boring but clear)**
```
@drawohara
[about] [contact] [cv] [disco] [io] [nerd] [now]
---
```

**Option C: Current approach (minimalist, discovery-based)**
```
@drawohara ❤️ 🖤
---
```

**Recommendation:** Keep Option C, it's very "you"

#### 2. File System Metaphor

**Use directory structure as visual language:**

```
/home/drawohara/
├── about/          # who
├── contact/        # reach out
├── cv/             # work history
├── disco/          # disco project
├── io/             # thoughts
│   ├── mission
│   ├── lost-in-the-desert
│   └── ...
├── nerd/           # tech stuff
│   ├── fastest-possible-embeddings
│   └── ...
├── jess/           # jess
└── now/            # current status
```

**Show this structure somehow?**
- Maybe in footer as "tree" output
- Maybe as navigation on inner pages
- Maybe not at all - keep it clean

#### 3. Breadcrumbs (Terminal Style)

```
drawohara.io:~ $ cd io
drawohara.io:~/io $ ls
mission  lost-in-the-desert  facebook-and-global-extremism  ...
drawohara.io:~/io $ cat mission/README.md
[content]
```

**Or simpler:**
```
/ → io → mission
```

**Or even simpler:**
```
← back
```

#### 4. Content Organization

**Keep current approach:**
- Short landing pages
- Direct language
- Links to deeper content
- No mystery

**Enhance with:**
- Clear hierarchy (when needed)
- Consistent structure
- Fast loading
- Obvious navigation

---

## Part 3: Technical Changes

### Remove Dependencies

**Kill:**
1. ✗ Pico CSS (70kb)
2. ✗ Turbo.js (30kb)
3. ✗ Google Analytics (tracking)
4. ✗ Multi-language support (unless actively used)
5. ✗ Complex meta tags

**Keep:**
1. ✓ Basic HTML5
2. ✓ Minimal inline CSS (<50 lines)
3. ✓ Basic meta tags (title, description)
4. ✓ Favicon
5. ✓ RSS feed (if you want)

### Simplify Layout

**Before:**
```erb
<html>
  <head>
    <!-- 40 lines of meta, links, scripts -->
  </head>
  <body>
    <header><%= header %></header>
    <main><%= content %></main>
    <footer><%= footer %></footer>
  </body>
</html>
```

**After:**
```erb
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= title %></title>
  <style>
    /* your 40 lines of CSS */
  </style>
</head>
<body>
  <header>
    <a href="/">@drawohara</a>
    <hr>
  </header>

  <main>
    <%= yield %>
  </main>

  <footer>
    <hr>
    <%= Time.now.year %> //
    <a href="/contact">contact</a>
  </footer>
</body>
</html>
```

### Performance

**Goals:**
- First paint < 100ms
- Total page weight < 50kb
- No external requests (except images)
- No JavaScript (unless needed)
- No tracking
- No frameworks

**How:**
- Inline CSS
- Minimal HTML
- No web fonts
- Static generation
- HTTP/2 server push (maybe)

### Privacy

**Remove:**
- Google Analytics
- Any tracking
- Third-party requests
- Cookies

**Maybe add:**
- Server-side analytics (if needed)
- Self-hosted, privacy-respecting
- Or just check server logs

---

## Part 4: Implementation Plan

### Phase 1: Minimal Viable Redesign

**Goal:** Strip to basics, test it

**Tasks:**

1. **Create new layout template** (`views/layout-minimal.erb`)
   - Inline CSS only
   - No external deps
   - Basic structure

2. **Test on one page** (/)
   - Make sure it works
   - Check dark mode
   - Verify mobile

3. **Refine CSS**
   - Adjust spacing
   - Fix dark mode
   - Test typography

4. **Compare:**
   - Load time: before/after
   - Page weight: before/after
   - Feel: subjective assessment

5. **Iterate:**
   - Too minimal? Add what's needed
   - Still bloated? Cut more

**Timeline:** 1-2 hours

### Phase 2: Apply to All Pages

**Tasks:**

1. **Update all page templates**
   - Use new layout
   - Remove framework CSS
   - Test each page

2. **Navigation decisions**
   - Terminal-style header?
   - Simple links?
   - Keep current minimal approach?

3. **Content adjustments**
   - Any layout-specific markdown?
   - Image handling?
   - Code blocks?

4. **Test thoroughly**
   - All pages load
   - Links work
   - Mobile works
   - Dark mode works

**Timeline:** 2-4 hours

### Phase 3: Information Architecture

**Tasks:**

1. **Review structure**
   - Current paths make sense?
   - Any consolidation needed?
   - Any new top-level pages?

2. **Navigation enhancement**
   - Make discovery easier (if needed)
   - Add breadcrumbs (if useful)
   - Terminal metaphor (if cool)

3. **Content audit**
   - Remove cruft
   - Simplify language
   - Check links

4. **Sitemap clarity**
   - Can you find anything in 2 clicks?
   - Is structure obvious?
   - Does it feel hackery?

**Timeline:** 2-4 hours

### Phase 4: Details & Polish

**Tasks:**

1. **Typography refinement**
   - Line height
   - Font size
   - Code blocks
   - Headings

2. **Color adjustments**
   - Link colors
   - Dark mode tweaks
   - Contrast checks
   - Terminal authenticity

3. **Interactions**
   - Link hover states
   - Focus states (keyboard nav)
   - Active states

4. **Edge cases**
   - Long URLs
   - Long code blocks
   - Large images
   - Tables (if any)

**Timeline:** 1-2 hours

### Phase 5: Deploy & Iterate

**Tasks:**

1. **Deploy to staging** (if you have one)
2. **Test in real browsers**
3. **Get feedback** (or don't)
4. **Deploy to production**
5. **Watch server logs** (instead of analytics)
6. **Iterate based on feel**

**Timeline:** 30 minutes + ongoing

---

## Part 5: Design Decisions

### A or B Choices

#### Navigation Style

**Option A: Explicit Terminal**
```
$ ls /home/drawohara
about contact cv disco io jess nerd now
```

**Option B: Minimal Links**
```
@drawohara :: about | contact | cv | disco | io | nerd | now
```

**Option C: Current (no visible nav)**
```
@drawohara ❤️ 🖤
---
```

**Recommendation:** C → Keep the mystery, navigation emerges from content

#### Header Style

**Option A: Current**
```erb
<a href="/">@drawohara</a> ❤️ 🖤
<hr>
```

**Option B: Terminal Prompt**
```erb
drawohara.io:~$ _
<hr>
```

**Option C: Even More Minimal**
```erb
<a href="/">@drawohara</a>
<hr>
```

**Recommendation:** A or C, depends on if you want the email heart/hate links

#### Footer Style

**Option A: Current (quotes + links)**
```erb
<hr>
<a href="/goto">→ goto</a>

> [random quote]
  — [author]

<a href="/">← eject</a>
```

**Option B: Minimal**
```erb
<hr>
<%= Time.now.year %> :: <a href="/contact">contact</a>
```

**Option C: Terminal**
```erb
<hr>
$ exit
Connection to drawohara.io closed.
```

**Recommendation:** B → Quotes are cool but maybe overkill

#### Typography

**Option A: All Monospace**
```css
* { font-family: monospace; }
```

**Option B: Monospace for code, sans-serif for text**
```css
body { font-family: -apple-system, sans-serif; }
code { font-family: monospace; }
```

**Recommendation:** A → Commit to the terminal aesthetic

#### Color Scheme

**Option A: Terminal Classic**
- Light: white bg, black text, blue links
- Dark: black bg, green text, green links

**Option B: GitHub Style**
- Light: white bg, #333 text, #0066cc links
- Dark: #0d1117 bg, #c9d1d9 text, #58a6ff links

**Option C: Minimal**
- Light: white bg, black text, black links (underlined)
- Dark: black bg, white text, white links (underlined)

**Recommendation:** B or C, both work, C is most minimal

---

## Part 6: Before & After

### Before

**Page weight:**
- HTML: 5kb
- Pico CSS: 70kb
- Turbo JS: 30kb
- Analytics: 15kb
- **Total: ~120kb + external requests**

**Complexity:**
- Framework CSS
- SPA navigation
- Analytics tracking
- Multi-language
- Fighting framework with custom CSS

**Feel:**
- Clean but generic
- Framework-y
- Not quite "you"

### After

**Page weight:**
- HTML: 5kb
- Inline CSS: 2kb
- **Total: ~7kb, no external requests**

**Complexity:**
- Raw HTML
- Simple CSS
- No JavaScript
- No tracking
- No fighting

**Feel:**
- Brutally simple
- Fast as hell
- Unique
- Hackery
- You

---

## Part 7: Testing Criteria

### How to Know It's Done

**Visual:**
1. ✓ Loads instantly
2. ✓ Looks plain but intentional
3. ✓ Works without CSS (progressive enhancement)
4. ✓ Dark mode just works
5. ✓ Monospace feels right
6. ✓ No framework smell

**Information Architecture:**
1. ✓ Can find anything in < 10 seconds
2. ✓ Structure is obvious
3. ✓ No mystery meat navigation
4. ✓ URLs are clean and guessable
5. ✓ Breadcrumbs work (if added)
6. ✓ Makes sense to non-technical people

**Technical:**
1. ✓ No external requests
2. ✓ < 50kb total page weight
3. ✓ Works in lynx (text browser)
4. ✓ No JavaScript errors (because no JS)
5. ✓ Valid HTML5
6. ✓ No tracking/privacy concerns

**Feel:**
1. ✓ Fast
2. ✓ Hackery
3. ✓ Honest
4. ✓ You
5. ✓ Not trying too hard
6. ✓ Just... right

---

## Implementation Sketch

### New `views/layout-minimal.erb`

```erb
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= exports[:title] || 'drawohara' %></title>

  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      max-width: 42rem;
      margin: 2rem auto;
      padding: 0 1rem;
      font: 16px/1.6 'SFMono-Regular', Consolas, monospace;
      color: #333;
      background: #fff;
    }

    h1, h2, h3 { margin: 1.5rem 0 0.5rem; }
    p { margin: 0.5rem 0; }
    a { color: #0066cc; text-decoration: none; }
    a:hover { text-decoration: underline; }

    code, pre {
      background: #f5f5f5;
      padding: 0.1em 0.3em;
    }

    pre {
      padding: 1rem;
      overflow-x: auto;
    }

    hr {
      border: none;
      border-top: 1px solid #ddd;
      margin: 1rem 0;
    }

    @media (prefers-color-scheme: dark) {
      body { color: #ddd; background: #111; }
      a { color: #58a6ff; }
      code, pre { background: #222; }
      hr { border-top-color: #333; }
    }
  </style>
</head>

<body>
  <header>
    <a href="/">@drawohara</a>
    <hr>
  </header>

  <main>
    <%= yield %>
  </main>

  <footer>
    <hr>
    <%= Time.now.year %> :: <a href="/contact">contact</a>
  </footer>
</body>
</html>
```

**That's it. Under 60 lines total.**

---

## Final Checklist

### Before You Start

- [ ] Backup current site
- [ ] Test in staging
- [ ] Save current analytics (if you care)
- [ ] Document current performance

### During Implementation

- [ ] Create `views/layout-minimal.erb`
- [ ] Test on index page
- [ ] Refine CSS
- [ ] Apply to all pages
- [ ] Remove Pico CSS
- [ ] Remove Turbo JS
- [ ] Remove Google Analytics
- [ ] Test all pages
- [ ] Test mobile
- [ ] Test dark mode
- [ ] Test in multiple browsers
- [ ] Test accessibility (keyboard nav)

### After Deploy

- [ ] Check load times
- [ ] Check page weights
- [ ] Check server logs (instead of analytics)
- [ ] Get feedback (or don't)
- [ ] Iterate if needed
- [ ] Ship updates

---

## Success Metrics

### Quantitative

- Page load time: < 100ms (from ~500ms)
- Page weight: < 10kb (from ~120kb)
- External requests: 0 (from ~5)
- Time to interactive: instant (from ~1s)

### Qualitative

- Feels fast: ✓
- Feels honest: ✓
- Feels like you: ✓
- Feels hackery: ✓
- Not trying too hard: ✓

### The Real Test

**Open the site. Does it feel like a terminal?**

**Open the source. Can you read it all in 2 minutes?**

**Show it to a hacker. Do they nod?**

If yes to all three: ship it.

---

## Alternative: Nuclear Option

### If You Want to Go EVEN MORE Minimal

**Single file site:**

```html
<!DOCTYPE html>
<title>drawohara</title>
<style>
  body {
    max-width: 42rem;
    margin: 2rem auto;
    padding: 0 1rem;
    font: 16px/1.6 monospace;
  }
  a { color: blue; }
  @media (prefers-color-scheme: dark) {
    body { background: #111; color: #ddd; }
    a { color: #58a6ff; }
  }
</style>

<h1>drawohara</h1>

<p>software architect. mountaineer. alaska → colorado.</p>

<ul>
  <li><a href="mailto:drawohara@drawohara.io">email</a>
  <li><a href="https://github.com/ahoward">github</a>
  <li><a href="/cv">cv</a>
</ul>

<h2>writing</h2>
<ul>
  <li><a href="/io/mission">mission</a>
  <li><a href="/io/lost-in-the-desert">lost in the desert</a>
  <li><a href="/io">more...</a>
</ul>

<h2>code</h2>
<ul>
  <li><a href="/nerd/fastest-possible-embeddings">fastest embeddings</a>
  <li><a href="/nerd">more...</a>
</ul>
```

**That's the whole site. 30 lines.**

Probably too extreme, but it would be fast as hell.

---

## Recommendation

### Start Here

1. **Create minimal layout** (Phase 1)
2. **Test on index page**
3. **If it feels right, apply everywhere** (Phase 2)
4. **Iterate on details** (Phase 4)
5. **Ship it**

### Timeline

- **Minimum:** 2 hours (just the visual redesign)
- **Complete:** 8-12 hours (visual + IA + polish)
- **Maximum:** 2 days (if you go deep on terminal aesthetic)

### First Step

Create `views/layout-minimal.erb` with the template above and update `ro/pages/index` to use it.

Test it. Feel it. Iterate.

---

> "simple beats clever. every. single. time."

Ship the simplest thing that feels right. You'll know when it's done.
