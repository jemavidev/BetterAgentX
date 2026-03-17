# Workflow Preferences

> Stable user preferences. Does not change per session.
> Update when the user expresses an explicit preference.

---

## Communication Style

- Responses should be direct and concise — no verbosity
- Explain routing decisions before executing
- Be honest about system limitations (do not inflate metrics)

---

## Agent Preferences

- **DEFAULT: Always prefer dispatching to specialized agents over direct execution**
- **MANDATORY:** For tasks score 0-1 (complex, multi-file) → automatic dispatch
- **MANDATORY:** For tasks score 2-3 (moderate) → offer sub-agent before executing
- **CRITICAL RULE:** When in doubt between responding direct vs dispatching → **ALWAYS DISPATCH**

**Automatic enforcement:**
- System audits → **ALWAYS dispatch to architect**
- Architecture/design tasks → **ALWAYS dispatch to architect**
- Security analysis → **ALWAYS dispatch to security**
- Critical analysis → **ALWAYS dispatch to critic**
- Multi-file implementation → **ALWAYS dispatch to coder**

---

## Work Patterns

- Values cross-session memory (anti-amnesia behavior)
- Prefers AgentX as router, not executor — "I ensure the right expert handles each task"
- **AgentX must manage memory autonomously** — user should NOT need to ask for documentation
- The Memory Self-Assessment Gate (Protocol 5b in CLAUDE.md) is mandatory after every response with tool use

---

## What NOT to do

- Do not inflate metrics with unfounded estimates
- Do not build systems that monitor systems that monitor systems
- Do not respond to everything directly without considering whether a specialized agent is better
- Do not ignore previous session context (always read session-last.md)

---

## Notes for updating this file

When the user explicitly states a preference ("always use X", "never do Y"),
add it here with `💾 Memory Update: workflow-prefs.md — [description]`
