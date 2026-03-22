---
inclusion: always
---

# Architecture Decisions

Recent architecture decisions from the team:


## DEC-10: SHA256 + Git dual-layer integrity protection for system files
**Date:** 2026-03-21T21:03:35-0500
**Agent:** architect
**Status:** implemented

**Context:** System files (.claude/scripts/, CLAUDE.md, settings.local.json) had no protection against direct modification when BetterAgents is installed in a target project — Claude could audit or edit them like any other file

**Decision:** See decision-log.json for details


## DEC-09: Per-response memory gate via Stop hook + flag mechanism
**Date:** 2026-03-20T13:06:14-0500
**Agent:** agentx
**Status:** implemented

**Context:** Protocol §5b (memory self-assessment) was purely declarative — Claude could skip it with no consequence. No runtime mechanism existed to detect if files were changed but memory was not written within a response.

**Decision:** See decision-log.json for details


## DEC-08: Dual memory path: .claude/ for dev, .betteragents/ for runtime
**Date:** 2026-03-18T06:45:45-0500
**Agent:** architect
**Status:** implemented

**Context:** Dev and runtime installations use different directory structures — same scripts need different base paths depending on where BetterAgents is installed

**Decision:** Use .claude/memory/ as the memory path for this dev repo (BetterAgents-K) and .betteragents/memory/ for all projects that install via the installer, keeping dev and runtime completely separate.


## DEC-07: exit-1 strategy to enforce memory writes at session end
**Date:** 2026-03-18T06:45:41-0500
**Agent:** architect
**Status:** implemented

**Context:** Memory was written silently to .memory-debt.md which Claude never saw — no mechanism forced writes, protocols were passive suggestions

**Decision:** Use exit 1 in on-session-stop.sh when memory debt is detected so Claude Code blocks the session stop and forces the agent to write memory before the session closes.


## DEC-06: Kiro memory integration via wrapper script
**Date:** 2026-03-02T10:01:56-0500
**Agent:** architect
**Status:** implemented

**Context:** Kiro lacks native hooks like Claude Code for automatic memory updates

**Decision:** Create .kiro/scripts/update-memory.sh as a thin wrapper that bridges Kiro's manual invocation model to the same .claude/scripts/ memory helpers used by Claude Code hooks.


---
**Source:** .claude/memory/decision-log.json
**Generated:** 2026-03-22T02:32:35.753Z
