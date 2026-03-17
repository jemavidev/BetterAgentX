#!/usr/bin/env bash
# AgentX Identity Enforcer — UserPromptSubmit hook
# Only injects reminder for substantive messages (>20 chars)
# Skips trivial responses like "ok", "sí", "gracias", "yes", etc.

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

# Fallback: if jq fails or no .prompt field, use raw input
if [ -z "$MSG" ]; then
  MSG="$INPUT"
fi

MSG_LEN=${#MSG}

# Token accumulator — append prompt char count for session-end estimation
# Final input tokens = sum(all MSG_LEN) / 4 + 2386 (fixed overhead: CLAUDE.md + MEMORY.md)
TOKENS_TMP="$(dirname "${BASH_SOURCE[0]}")/../memory/.session-tokens-tmp"
echo "$MSG_LEN" >> "$TOKENS_TMP" 2>/dev/null || true

# Prompt log — store first 200 chars of each substantive prompt for Session Activity
# Strip system-injected XML tags (<ide_opened_file>, <system-reminder>, etc.) first
# Used by track-usage.sh at session end to populate activity.prompts in llm-usage.json
if [ "$MSG_LEN" -ge 20 ]; then
    PROMPTS_TMP="$(dirname "${BASH_SOURCE[0]}")/../memory/.session-prompts-tmp"
    CLEAN_MSG=$(echo "$MSG" | sed 's/<[^>]*>[^<]*<\/[^>]*>//g; s/<[^>]*>//g' | sed 's/^[[:space:]]*//' | tr -s ' ' | tr '\n' ' ')
    CLEAN_LEN=${#CLEAN_MSG}
    if [ "$CLEAN_LEN" -ge 5 ]; then
        echo "$CLEAN_MSG" | head -c 200 | jq -Rc . >> "$PROMPTS_TMP" 2>/dev/null || true
    fi
fi

# Memory debt injection — if previous session left unpersisted work
DEBT_FILE="$(dirname "${BASH_SOURCE[0]}")/../memory/.memory-debt.md"
if [ -f "$DEBT_FILE" ]; then
    cat "$DEBT_FILE"
    rm -f "$DEBT_FILE"
fi

# Skip injection for very short/trivial messages
if [ "$MSG_LEN" -lt 20 ]; then
  exit 0
fi

echo "🧠 [SYSTEM REMINDER — AgentX Identity Protocol]"
echo "You are AgentX, the orchestrator of BetterAgents."
echo "MANDATORY: Begin your response with the identity header:"
echo '---'
echo '🧠 AgentX/[Mode]'
echo '---'
echo "Where [Mode] is: Dispatcher | Architect | Coder | Critic | Researcher | etc."
echo "Read .betteragents/memory/MEMORY.md if not yet loaded this session."
echo "Apply the 4-D methodology: Deconstruct → Diagnose → Develop → Dispatch."
