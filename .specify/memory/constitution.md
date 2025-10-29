<!--
Sync Impact Report:
- Version: 1.0.0 (initial constitution)
- Created: 2025-10-29
- Based on: ./ai/CODE.md, ./ai/WRITING.md, ./ai/PHOTOGRAPHY.md
- Templates requiring updates: ✅ All templates compatible with initial constitution
-->

# drawohara.io Constitution

## Core Principles

### I. Simplicity Over Cleverness

**Simple beats clever. Every. Single. Time.**

Code, writing, and design must prioritize:
- Direct solutions over abstraction
- Readable code over performance tricks (until measured)
- Clear prose over academic language
- Natural photography over processed aesthetics

**Rationale**: Complexity compounds. Each grain of cognitive dissonance moves the solution farther away. 30 years and 143 gems proved simple wins.

### II. Truth Over Embellishment

**Show what's real. No BS.**

All work must maintain honesty:
- Code: No defensive programming for imaginary edge cases
- Writing: Challenge conventional wisdom with evidence, not opinion
- Photography: Natural representation, minimal processing
- Documentation: Acknowledge limitations and work-in-progress

**Rationale**: Authenticity builds trust. Manufactured perfection wastes time. Instagram aesthetics don't solve problems.

### III. Plaintext Supremacy

**The power of plaintext is absolute.**

All knowledge and documentation MUST be:
- Stored in markdown/plaintext format
- Version-controllable and diff-able
- grep-able and human-readable
- AI-portable across any system/tool
- Free of proprietary formats or lock-in

**Rationale**: Plaintext is timeless. Future AI agents need context. Binary formats die. Plaintext persists.

### IV. Direct Communication

**Say what you mean. Show your work.**

Communication must be:
- Direct and conversational (no corporate speak)
- Evidence-based (code examples, methodology, data)
- Short paragraphs (1-3 sentences)
- TL;DR summaries for complex content
- WHY not WHAT in comments and explanations

**Rationale**: Time is finite. Clarity is kindness. Fluff is disrespect.

### V. Test-First Discipline

**Tests are scripture. Code is sand.**

Testing requirements:
- Executable scripts: `if $0 == __FILE__` usage examples
- Libraries: Inline tests or separate test files
- Features: Tests written before implementation
- Integration points: Contract tests MUST exist
- Specifications: Treated as prophecy

**Rationale**: Untested code is wishful thinking. Tests document intent. Breaking changes surface immediately.

### VI. Ruby Idioms (When Using Ruby)

**Use the language. Don't fight it.**

Required patterns:
- `test()` for file checks (not File.exist?)
- IO.binread/binwrite (never File.read/write)
- Fattr for class-level attributes
- Map for flexible data structures
- Guards and early returns
- Splat operators for flexible args
- `.tap` for chaining side effects
- Heredocs with `____` delimiters
- Section markers: `# comments` for visual separation

**Rationale**: Ruby is a VHLL. These patterns appear in 143 gems. They work.

### VII. Atomic Operations

**No partial states. Ever.**

File operations MUST be atomic:
- Write to temp file with UUID suffix
- Move to final location (atomic on most filesystems)
- Clean up temp in ensure block
- Use lockfiles for cross-process safety
- Use mutexes for cross-thread safety

**Rationale**: Partial writes corrupt data. NFS exists. Concurrent access happens. 99.9% of developers are DEAD WRONG about transactions.

### VIII. Minimal Dependencies

**Stdlib is underrated. Frameworks are overrated.**

Dependency rules:
- Prefer stdlib over gems
- Each dependency must justify existence
- Version constraints explicit and tested
- No ActiveSupport monkey patches
- Local dev: test(?e) to use local gems
- Document why each dependency exists

**Rationale**: Dependencies are liabilities. They change. They break. They bloat. Stdlib is battle-tested.

## Writing Standards

### Content Creation

All writing (blog posts, documentation, commit messages) must follow:

- **Voice**: Direct, conversational, authoritative. Use "you" and "I"
- **Structure**: TL;DR first, short paragraphs, numbered lists for steps
- **Evidence**: Show code examples, methodology, actual data
- **Honesty**: Acknowledge limitations, work-in-progress, failures
- **Humor**: Sarcasm earned, self-deprecating welcome, no corporate cheerleading
- **Lowercase**: For contemplative/personal pieces (creates intimacy)
- **Deliberate Misspellings**: Hacker aesthetic permitted (e.g., "pythong"). Ask before "fixing"

### Technical Writing

Must include:
1. TL;DR - One sentence summary
2. The Problem - What conventional wisdom gets wrong
3. Evidence - Code, data, methodology
4. Reasoning - Show your math/logic
5. Conclusion - What actually works
6. Practical Application - How to use this

### Forbidden Language

Never use:
- "Leverage" (say "use")
- "Utilize" (say "use")
- "In order to" (say "to")
- "Due to the fact that" (say "because")
- "At this point in time" (say "now")
- Corporate speak or buzzwords

## Photography Principles

### Approach

All photography must prioritize:
- **Natural over processed**: No heavy HDR, oversaturation, or artificial drama
- **Story over specs**: Photos serve narrative, not technical demonstration
- **Truth over beauty**: When they conflict, choose honest representation
- **Documentary style**: Real moments, not staged or posed
- **Minimal editing**: Correct exposure/white balance, slight contrast, done
- **Context matters**: Show the whole scene, include the struggle

### Subject Matter

Primary subjects:
1. Natural landscapes (Alaska, Colorado mountains, desert)
2. Adventure documentation (bike touring, skiing, mountaineering)
3. Dogs (being dogs)
4. People in context (documentary, not portrait)

### Processing Rules

- Does it look like what you saw? (primary test)
- Minimal adjustments only
- Maintain natural colors
- No Instagram presets or trend-chasing
- If Instagram wouldn't like it but it's true, that's probably good

## AI-Portable Philosophy

### Documentation Strategy

All project knowledge MUST be:
- Stored in AI-portable fashion (plaintext/markdown)
- Available in `./ai/` directory for any AI system
- Tool-specific connections in respective config files
- Future sessions can understand context without handoff
- Memory through files, not hidden state

### Pattern

1. Store actual content in `./ai/` (AI-agnostic)
2. Store connection mechanism in tool-specific locations:
   - `.claude/context.md` for Claude Code
   - `.cursorrules` for Cursor
   - `.github/copilot-instructions.md` for GitHub Copilot

This maintains one source of truth while connecting to different AI systems.

## Development Workflow

### Implementation Process

1. **Understand**: Read existing code patterns, follow established idioms
2. **Plan**: Simple first, YAGNI principles, measure before optimizing
3. **Write**: Tests first (if applicable), then implementation
4. **Review**: Guards in place? Early returns? Atomic operations? Dependencies justified?
5. **Ship**: Done is better than perfect

### Code Review Requirements

All code must verify:
- [ ] Follows established patterns from CODE.md
- [ ] Uses proper Ruby idioms (test(), IO.binread, guards, etc.)
- [ ] Atomic file operations with ensure blocks
- [ ] Minimal dependencies, each justified
- [ ] Tests exist (inline or separate)
- [ ] No premature optimization
- [ ] Comments explain WHY not WHAT
- [ ] Section markers for visual organization

### Writing Review Requirements

All writing must verify:
- [ ] TL;DR provided for complex content
- [ ] Direct voice, no corporate speak
- [ ] Evidence provided (code, data, methodology)
- [ ] Short paragraphs (1-3 sentences)
- [ ] Honest about limitations
- [ ] Deliberate misspellings are intentional, not errors

## Governance

### Amendment Process

Constitution changes require:
1. Documentation of reasoning
2. Version bump (MAJOR for backward incompatible, MINOR for additions, PATCH for clarifications)
3. Update of dependent templates in `.specify/templates/`
4. Sync Impact Report at top of this file
5. Commit message: `docs: amend constitution to vX.Y.Z (description)`

### Versioning Policy

- **MAJOR**: Backward incompatible governance/principle removals or redefinitions
- **MINOR**: New principle/section added or materially expanded guidance
- **PATCH**: Clarifications, wording, typo fixes, non-semantic refinements

### Compliance

- All PRs/reviews must verify constitution compliance
- Complexity must be justified
- Violations require explicit approval with rationale
- This constitution supersedes all other practices

### Runtime Guidance

For ongoing development, consult:
- `./ai/CODE.md` - Detailed Ruby patterns and idioms
- `./ai/WRITING.md` - Complete writing style guide
- `./ai/PHOTOGRAPHY.md` - Photography philosophy
- `.claude/context.md` - Claude Code integration guide

**Version**: 1.0.0 | **Ratified**: 2025-10-29 | **Last Amended**: 2025-10-29
