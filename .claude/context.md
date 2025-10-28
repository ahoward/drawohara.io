# Project Context

## AI Guidelines
This project maintains AI agent guidelines in the `/ai/` directory. These are AI-agnostic resources that can be used by any AI system.

## Writing Style
When helping with any writing tasks (blog posts, documentation, READMEs, commit messages), refer to the writing style guide at `/ai/WRITING.md`.

Key principles:
- Direct, conversational, authoritative
- TL;DR summaries for complex content
- Short paragraphs (1-3 sentences)
- Show code examples, methodology, reasoning
- Challenge conventional wisdom with evidence
- No corporate speak or fluff

See `/ai/WRITING.md` for complete guidelines.

## Code Style
When writing or reviewing code (Ruby, JavaScript, etc.), refer to the coding style guide at `/ai/CODE.md`.

Key principles:
- Simplicity over cleverness
- Direct, readable code
- Use language features, not frameworks when possible
- Method names explain intent
- Guards and early returns
- Ruby idioms: splat operators, tap, fetch with blocks

See `/ai/CODE.md` for complete guidelines.

## Photography Style
When discussing or generating photography-related content, refer to `/ai/PHOTOGRAPHY.md`.

Key principles:
- Natural over processed
- Story over specs
- Truth over beauty (when they conflict)
- Minimal editing, honest representation
- Documentary approach
- Adventure and landscape focus

See `/ai/PHOTOGRAPHY.md` for complete philosophy.

## Documentation Philosophy

### The Power of Plaintext
- All documentation in markdown/plaintext format
- Human-readable, version-controllable, timeless
- No proprietary formats, no lock-in
- grep-able, diff-able, portable

### AI-Portable Knowledge
- We *always* document in an AI-portable fashion
- Future AI agents should be able to understand context
- Knowledge stored in /ai/ directory is AI-agnostic
- Can be used by any AI system, any tool, any future technology
- Plain text files are the ultimate portable format

### Memory Through Files
- Don't rely on session memory or hidden state
- Write it down in context files
- If it's important to remember, it goes in plaintext
- Future sessions should find what past sessions learned
