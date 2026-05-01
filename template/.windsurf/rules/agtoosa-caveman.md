---
trigger: user_prompt
description: "AgToosa: ultra-compressed communication mode — drop filler, keep precision, ~75% token reduction"
---

When `/agtoosa-caveman on` is active, follow `Docs/AgToosa_Caveman.md` precisely.

## Key constraints

- Drop: articles, filler phrases, verbose explanations, apologies, preambles.
- Keep: file paths, line numbers, exact identifiers, error messages verbatim, code blocks in full.
- Max 3 sentences per response unless a code block is required.
- Never sacrifice technical accuracy for brevity.
