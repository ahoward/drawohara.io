# GitHub Issues → Micro Blog System

## Concept

Use GitHub issues as a micro-blogging interface. Robot processes issues → generates ro content → commits to `public/ro/microblog/` → triggers rebuild → live on site.

## Architecture

```
GitHub Issue (labeled 'microblog')
    ↓
GitHub Actions Workflow
    ↓
Parse issue → Generate YAML
    ↓
Commit to public/ro/microblog/ISSUE_NUMBER.yml
    ↓
Site rebuild (existing CI or manual)
    ↓
Content live at /microblog or /m
```

## Issue Template

**File:** `.github/ISSUE_TEMPLATE/microblog.yml`

```yaml
name: Microblog Post
description: Create a micro-blog entry
title: "[microblog] "
labels: ["microblog"]
body:
  - type: markdown
    attributes:
      value: |
        Quick post. Keep it simple.

  - type: input
    id: title
    attributes:
      label: Title
      description: Post title (optional - uses issue title if blank)

  - type: textarea
    id: content
    attributes:
      label: Content
      description: Your post content (markdown supported)
    validations:
      required: true

  - type: input
    id: kind
    attributes:
      label: Kind
      description: Post type
      placeholder: note, link, thought, code
      value: note

  - type: input
    id: tags
    attributes:
      label: Tags
      description: Comma-separated tags
      placeholder: ruby, climbing, alaska
```

## GitHub Actions Workflow

**File:** `.github/workflows/microblog.yml`

```yaml
name: Microblog → ro

on:
  issues:
    types: [opened, edited, labeled]

jobs:
  process-microblog:
    # Only run if issue has 'microblog' label
    if: contains(github.event.issue.labels.*.name, 'microblog')

    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3.5'

      - name: Process issue to ro content
        env:
          ISSUE_NUMBER: ${{ github.event.issue.number }}
          ISSUE_TITLE: ${{ github.event.issue.title }}
          ISSUE_BODY: ${{ github.event.issue.body }}
          ISSUE_URL: ${{ github.event.issue.html_url }}
          ISSUE_CREATED: ${{ github.event.issue.created_at }}
          ISSUE_UPDATED: ${{ github.event.issue.updated_at }}
        run: |
          bin/issue-to-microblog

      - name: Commit changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add public/ro/microblog/
          git diff --staged --quiet || git commit -m "microblog: add/update issue #${{ github.event.issue.number }}"
          git push

      - name: Trigger rebuild (optional)
        run: |
          # Could trigger Vercel/Netlify/etc rebuild here
          # Or rely on push hook to trigger deployment
          echo "Site will rebuild on push"
```

## Content Generation Script

**File:** `bin/issue-to-microblog`

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'time'
require 'fileutils'

MICROBLOG_DIR = 'public/ro/microblog'

# Parse issue data from env vars
issue_number = ENV['ISSUE_NUMBER']
issue_title = ENV['ISSUE_TITLE']
issue_body = ENV['ISSUE_BODY']
issue_url = ENV['ISSUE_URL']
issue_created = ENV['ISSUE_CREATED']
issue_updated = ENV['ISSUE_UPDATED']

# Parse issue form fields from body (GitHub issue templates format)
def parse_form_data(body)
  data = {}
  current_field = nil

  body.split("\n").each do |line|
    # Match "### Field Name" headers
    if line.match(/^###\s+(.+)/)
      current_field = $1.downcase.gsub(/\s+/, '_')
      data[current_field] = ''
    elsif current_field && !line.strip.empty?
      data[current_field] << line + "\n"
    end
  end

  data.transform_values(&:strip)
end

form_data = parse_form_data(issue_body)

# Extract title (use form title or issue title)
title = if form_data['title'] && !form_data['title'].empty?
  form_data['title']
else
  issue_title.sub(/^\[microblog\]\s*/, '')
end

# Build YAML frontmatter
entry = {
  'title' => title,
  'timestamp' => Time.parse(issue_created).iso8601,
  'updated' => Time.parse(issue_updated).iso8601,
  'kind' => form_data['kind'] || 'note',
  'url' => issue_url,
  'issue' => issue_number.to_i
}

# Add tags if present
if form_data['tags'] && !form_data['tags'].empty?
  entry['tags'] = form_data['tags'].split(',').map(&:strip)
end

# Content is the 'content' field from form
content = form_data['content'] || ''

# Write to file
FileUtils.mkdir_p(MICROBLOG_DIR)
filepath = File.join(MICROBLOG_DIR, "#{issue_number}.yml")

File.write(filepath, entry.to_yaml)
File.write(filepath, "---\n\n#{content}\n", mode: 'a')

puts "Created #{filepath}"
```

## Site Integration

### Route Handler

**In `config/site.rb`:**

```ruby
# /microblog or /m
site.route '/m' do |route|
  route.call do |ctx|
    # Load all microblog entries
    entries = []

    Dir.glob('public/ro/microblog/*.yml').each do |path|
      begin
        content = IO.binread(path)
        yaml = YAML.safe_load(content, permitted_classes: [Time, Date], aliases: true)

        # Parse timestamp
        yaml['timestamp'] = Time.parse(yaml['timestamp'].to_s) if yaml['timestamp']

        entries << Map.for(yaml)
      rescue => e
        warn "Skipping #{path}: #{e.message}"
      end
    end

    # Sort newest first
    entries = entries.sort_by { |e| e['timestamp'] }.reverse

    ctx.render 'views/microblog.erb', data: { entries: }
  end

  route.urls do
    %w[ /m ]
  end
end
```

### Template

**File:** `views/microblog.erb`

```erb
<%
exports[:title] = 'microblog'
exports[:description] = 'quick thoughts, links, notes'
%>

<style>
.microblog-entry {
  margin: 2rem 0;
  padding-bottom: 1rem;
  border-bottom: 1px solid #ddd;
}

.microblog-entry:last-child {
  border-bottom: none;
}

.microblog-meta {
  font-size: 0.85em;
  color: #666;
  margin-bottom: 0.5rem;
}

.microblog-kind {
  display: inline-block;
  padding: 0.1em 0.4em;
  background: #f0f0f0;
  border-radius: 2px;
  font-size: 0.9em;
  margin-right: 0.5rem;
}

@media (prefers-color-scheme: dark) {
  .microblog-entry {
    border-bottom-color: #333;
  }

  .microblog-meta {
    color: #888;
  }

  .microblog-kind {
    background: #222;
  }
}
</style>

<h1>microblog</h1>

<% if data[:entries].empty? %>
  <p>nothing yet.</p>
<% else %>
  <% data[:entries].each do |entry| %>
    <article class="microblog-entry">
      <div class="microblog-meta">
        <span class="microblog-kind"><%= entry['kind'] %></span>
        <time datetime="<%= entry['timestamp'].iso8601 %>">
          <%= entry['timestamp'].strftime('%b %d, %Y') %>
        </time>
        <% if entry['tags'] %>
          <% entry['tags'].each do |tag| %>
            <span class="tag">#<%= tag %></span>
          <% end %>
        <% end %>
      </div>

      <% if entry['title'] %>
        <h2><%= entry['title'] %></h2>
      <% end %>

      <%= markdown(entry['body'] || '') %>

      <div class="microblog-meta">
        <a href="<%= entry['url'] %>">issue #<%= entry['issue'] %></a>
      </div>
    </article>
  <% end %>
<% end %>
```

## Implementation Checklist

- [ ] Create `.github/ISSUE_TEMPLATE/microblog.yml`
- [ ] Create `.github/workflows/microblog.yml`
- [ ] Create `bin/issue-to-microblog` script
- [ ] Make script executable: `chmod +x bin/issue-to-microblog`
- [ ] Create `public/ro/microblog/` directory
- [ ] Add route to `config/site.rb`
- [ ] Create `views/microblog.erb` template
- [ ] Test: Create test issue with 'microblog' label
- [ ] Verify: Check workflow runs and commits YAML
- [ ] Verify: Build site and check `/m` route
- [ ] Add link to microblog from main nav/footer

## Enhancements (Future)

- **RSS feed** for microblog at `/m.xml`
- **Per-kind filtering** via `/m?kind=link`
- **Tag pages** at `/m/tag/ruby`
- **Issue closing** = unpublish (delete YAML or add `published: false`)
- **Issue comments** → rendered on microblog entry
- **Webmentions** integration
- **Cross-posting** to Twitter/Mastodon via additional workflow

## Advantages

✓ **No database** - content in git, issues as CMS
✓ **Mobile friendly** - post from GitHub mobile app
✓ **Version control** - full history via git + issues
✓ **Comments built-in** - GitHub issue comments
✓ **No server** - pure static site + GitHub Actions
✓ **Offline editing** - create issues offline, sync later
✓ **API access** - GitHub Issues API for integrations

## Drawbacks

✗ **Public issues only** - can't have private posts (without private repo)
✗ **GitHub dependency** - tied to GitHub infrastructure
✗ **Workflow delays** - not instant (Actions queue time)
✗ **Rate limits** - GitHub API/Actions limits apply

## Alternative: Issue Labels as Commands

Instead of issue templates, use labels for commands:

- `microblog` - publish as microblog post
- `microblog:link` - specific kind
- `microblog:draft` - don't publish yet
- `microblog:delete` - remove from site

Simpler, more flexible, works with any issue format.

## Notes

- Bot needs write access to repo (use `GITHUB_TOKEN`)
- Consider branch protection - bot pushes directly to main
- Could use PR instead of direct commit for review
- Timestamp uses issue creation time (immutable)
- Updates preserve original timestamp, add 'updated' field
- Issue URL links back to source (transparency)
