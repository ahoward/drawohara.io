# Writing Style Guide

This document distills the writing patterns found in ara.t..howard's personal and technical writing, based on analysis of posts in ./ro/io, ./ro/nerd, and dojo4 blog posts.

## Core Principles

### 1. Get to the Point
- Start with TL;DR or summary when appropriate
- No fluff, no filler
- Short paragraphs for scannability
- If it can be said in fewer words, do it

### 2. Be Honest and Direct
- Strong opinions, loosely held
- Challenge conventional wisdom when it's wrong
- Acknowledge work-in-progress and limitations
- Don't be afraid to be provocative or controversial

### 3. Show, Don't Just Tell
- Include code examples for technical content
- Show methodology and reasoning
- Use math/logic to demonstrate points
- Link to actual implementations and results

## Voice and Tone

### Conversational but Authoritative
- Use "you" and "I" freely
- Write like you're talking to a peer
- Direct address to the reader
- Maintain technical credibility while being approachable

### Lowercase for Personal Voice
- Use lowercase in contemplative or personal pieces
- Creates intimacy and authenticity
- Example: "everyone should have a mission statement. here is mine."

### Humor and Irreverence
- Sarcasm is welcome when earned
- Use emojis strategically (e.g., 🐍 for Python)
- Self-deprecating humor works well
- Don't take yourself too seriously

### Deliberate Misspellings and Hacker Aesthetic
- As a hacker, deliberate misspellings are common for humor and style
- Examples: "pythong" (not python), creative variations on tech terms
- **Before "fixing" typos, ask first** - assume intentionality
- Hacker aesthetic > grammatical perfection
- If something looks weird, it's probably on purpose

## Formatting and Style

### Emphasis
- Use **bold** for strong points: `*DEAD* *WRONG*`
- Italics for secondary emphasis or quotes
- Block quotes for key takeaways or external content

### Structure
- Numbered lists for sequential content
- Short paragraphs (1-3 sentences often)
- Clear section headers
- Code blocks for technical examples

### Technical Writing
```ruby
# Always include actual, runnable code
# Show the before and after
# Comment thoughtfully but minimally
def example
  # this is good
end
```

## Content Patterns

### Technical Posts Should Include:
1. **TL;DR** - One sentence summary
2. **The Problem** - What conventional wisdom gets wrong
3. **Evidence** - Code, data, methodology
4. **Reasoning** - Show your math/logic
5. **Conclusion** - What actually works
6. **Practical Application** - How to use this

### Personal Posts Should:
- Ground abstract concepts in real experience
- Use narrative when appropriate
- Connect technical work to human meaning
- Be vulnerable when it serves the point

## Writing Techniques

### Challenge and Provoke
```markdown
> 99.9% of the web developer world believes X. They are *DEAD* *WRONG*.
```

### Show Your Work
- Include methodology for research
- Link to source code and examples
- Explain decision-making process
- Show alternative approaches considered

### Use Concrete Examples
- Personal anecdotes > abstract theory
- Real code > pseudo-code
- Actual numbers > hand-waving
- Specific tools/products > generic categories

### Cross-Reference Your Work
- Link to related projects: `[disco](/disco)`
- Reference past writing when relevant
- Build a connected body of work
- Show evolution of ideas

## What to Avoid

### Don't:
- Use corporate speak or buzzwords
- Hide behind passive voice
- Write long paragraphs (3+ sentences is pushing it)
- Include unnecessary qualifiers
- Be deliberately obscure
- Write before you've tested/verified
- Use 10 words when 3 will do

### Especially Avoid:
- "Leverage" (just say "use")
- "Utilize" (just say "use")
- "In order to" (just say "to")
- "Due to the fact that" (just say "because")
- "At this point in time" (just say "now")

## Specific Scenarios

### When Writing About Code:
1. Show actual, runnable examples
2. Include both good and bad versions
3. Explain *why* the pattern matters
4. Challenge accepted practices when appropriate
5. Include personal experience with the approach

### When Writing About Tools/Process:
1. Start with the practical problem
2. Show what you actually tried
3. Include the surprising results
4. Explain the reasoning/math
5. End with actionable takeaways

### When Writing Research/Analysis:
1. State methodology upfront
2. Link to raw data/results
3. Use real numbers and scale
4. Acknowledge limitations
5. Connect to practical implications

### When Being Controversial:
1. Lead with evidence, not opinion
2. Challenge ideas, not people
3. Offer concrete alternatives
4. Back claims with experience
5. Stay focused on technical merit

## Example Opening Patterns

### Technical Challenge:
```markdown
### TL;DR;
> everyone thinks X. they are wrong. here's why.
```

### Research Post:
```markdown
following is an AI generated summary of this article, so you won't have to read it!

> [summary]

today i [specific action taken]...
```

### Quick Tip:
```markdown
i stood up a little [thing] today.

ref: [link]

[minimal explanation, let the work speak]
```

### Personal Reflection:
```markdown
[lowercase, intimate opening]

___... this post is a work in progress ...___
```

## Final Notes

- These are patterns, not rules
- Break them when you have good reason
- The goal is clarity and honesty
- Technical accuracy > stylistic consistency
- If something doesn't work, say so
- Show your scars, not just your victories

---

> "each grain of cognitive dissonance in the code moves the solution farther away."

Write like someone who's been in the trenches, has the scars to prove it, and isn't interested in bullshit.
