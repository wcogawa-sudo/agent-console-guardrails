---
name: {{name}}
description: One or two sentences. What this does, then "Use when ..." with the words you'd actually type (tools, techniques, symptoms). This line is all the search sees, so make it specific.
domain: threat-hunting
tags: [elastic, sentinelone, windows]
attack: []
status: draft
last_verified: {{date}}
sources: []
origin: own
---

# Title in plain words

One short paragraph: what problem this solves and what a good result looks like.

## When to use
- The situation or question that should lead here.
- The words, alerts or symptoms that signal it.

**Not for:** nearby situations that belong to a different skill (name it).

## Prerequisites
- Data sources / logs / access needed, and what to do if one is missing (the check becomes "insufficient data", not "clean").
- Tools, and any client- or machine-specific rules that override this skill (e.g. soc-analyst ground rules, read-only via roq).

## Workflow
1. Step, with the exact query/command in a code block.
2. Step. Say what to look at in the output and what it means.
3. Decision point: if X, go to step N; if Y, stop and report.

## Verification
- **Positive control:** how to prove the query *can* match (something known to exist), so a zero means clean and not broken.
- How to confirm a result a second way (count vs aggregation, other console, raw rows).
- What "done" looks like.

## Pitfalls
- Traps that have already bitten: wrong field, silent zero, time zone, retention limit.
- Common false positives and how to tell them apart.

## References
- `references/<file>.md`: longer material loaded only when needed (field lists, query libraries).
- Sources behind the facts above (official docs, ATT&CK page), with the date checked.

## Update notes
- {{date}}: created.
