---
inclusion: always
---

# Reusable Patterns

Patterns identified and used in this project:


## manual-memory-wrapper
**Category:** implementation
**Used:** 0 times

**Problem:** Platform lacks native hooks for automatic memory updates

**Solution:** Create thin wrapper script that calls core memory scripts and auto-syncs generated files


## backwards-compatible-schema-evolution
**Category:** architectural
**Used:** 1 times

**Problem:** Add new fields as objects alongside old string fields. Use typeof checks in renderer to support both formats. Never break old data — migrate lazily on read, not on write.

**Solution:** Write new format for all new records going forward. Renderer detects format per entry with typeof f === 'object'. Objects get the rich treatment (heat-map, +N/-M display). Strings fall back to the legacy display (filename only). Old data is never touched. Migration is lazy and implicit — entries naturally upgrade as they are re-written by newer code. Only viable when the legacy display is still acceptable (degraded but not broken).


## index-based-onclick
**Category:** implementation
**Used:** 1 times

**Problem:** Store rendered items in a global array (window._safetyTabSessions); pass array index in onclick instead of serializing the full object to HTML attributes. Avoids encoding bugs with special characters in user-generated content.

**Solution:** Before rendering cards, store all data objects in a window global array (e.g. window._safetyTabSessions = data). In each card's onclick, pass only the numeric index: onclick='openModal(${i})'. Handler checks typeof arg === 'number' and retrieves window._array[i]. Zero serialization. Works for any payload including user prompts, JSON objects, file paths with spaces, or code snippets.


## memory-debt-cross-session
**Category:** architectural
**Used:** 1 times

**Problem:** Hook on session-stop writes .memory-debt.md if semantic files empty; hook on user-prompt injects+deletes it at next session start — enforcement fires exactly once

**Solution:** on-session-stop.sh scans decision-log.json, progress.json, and patterns.json — if all contain only baseline/template entries, writes .memory-debt.md with a timestamped debt reminder. on-user-prompt.sh at the very next session's first user message: reads the debt file, prepends its content to the prompt context, then deletes .memory-debt.md. Debt fires exactly once — no repeated warnings, no stale state across multiple sessions.


---
**Source:** .claude/memory/patterns.json
**Generated:** 2026-03-22T02:32:35.753Z
