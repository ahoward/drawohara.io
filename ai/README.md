# AI Agent Resources

This directory contains AI-agnostic guidelines and context that can be used by any AI system working on this project.

## Contents

- **WRITING.md** - Writing style guide for all content (blog posts, docs, commit messages)
- **CODE.md** - Coding conventions and patterns (Ruby primarily, principles apply broadly)
- **PHOTOGRAPHY.md** - Photography philosophy and approach (natural, story-driven, honest)

## Usage by AI System

### Claude Code
- Automatically loaded via `.claude/context.md`
- References resources in this directory

### Cursor / Other Editors
- Add to `.cursorrules` or equivalent: `Include guidelines from ./ai/ directory`

### ChatGPT / Web Interfaces
- Manually reference: "Follow the writing guidelines in ./ai/WRITING.md"

### API Usage
- Include as system context: `fs.readFileSync('./ai/WRITING.md')`

## Pattern

**General principle:**
1. Store the **actual content** in `./ai/` (AI-agnostic)
2. Store the **connection mechanism** in tool-specific locations:
   - `.claude/context.md` for Claude Code
   - `.cursorrules` for Cursor
   - `.github/copilot-instructions.md` for GitHub Copilot
   - etc.

This allows you to maintain one source of truth while connecting it to different AI systems.
