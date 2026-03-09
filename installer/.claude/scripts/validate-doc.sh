#!/bin/bash
# validate-doc.sh — Document Governance Validator (Advisory Mode)
# Triggered by on-file-write-verification.sh for .md files
# Checks naming conventions and required frontmatter metadata
# Mode: ADVISORY — always exits 0 (warns but never blocks)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_PATH="${1:-}"

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# --- SCOPE CHECK ---
# These files are excluded from governance validation
is_excluded() {
  local file="$1"
  local excluded_patterns=(
    ".claude/memory/"
    "session-last"
    "MEMORY.md"
    "CLAUDE.md"
    "governance.md"
    "README"
    "PHASE-"
    "CHANGELOG"
    ".gitkeep"
  )
  for pattern in "${excluded_patterns[@]}"; do
    if [[ "$file" == *"$pattern"* ]]; then
      return 0  # excluded
    fi
  done
  return 1  # not excluded
}

# Exit silently if file not provided or excluded
if [ -z "$FILE_PATH" ]; then
  exit 0
fi
if is_excluded "$FILE_PATH"; then
  exit 0
fi
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

FILENAME="$(basename "$FILE_PATH")"
WARNINGS=()

# --- NAMING CHECK ---
# Must be lowercase-with-hyphens.md, no dates (YYYY-MM-DD pattern)
if [[ "$FILENAME" =~ [A-Z] ]]; then
  WARNINGS+=("Filename has uppercase letters — use lowercase-with-hyphens.md")
fi
if [[ "$FILENAME" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
  WARNINGS+=("Filename contains a date — dates belong in the metadata header, not the filename")
fi
if [[ "$FILENAME" =~ _ ]]; then
  WARNINGS+=("Filename uses underscores — use hyphens instead (lowercase-with-hyphens.md)")
fi

# --- FRONTMATTER CHECK ---
REQUIRED_FIELDS=("title" "version" "date" "author" "status" "category")
MISSING_FIELDS=()

# Check if file starts with frontmatter block
FIRST_LINE=$(head -1 "$FILE_PATH" 2>/dev/null)
if [[ "$FIRST_LINE" != "---" ]]; then
  WARNINGS+=("Missing frontmatter block — document should start with --- metadata ---")
  # All fields are missing if no frontmatter
  MISSING_FIELDS=("${REQUIRED_FIELDS[@]}")
else
  # Extract frontmatter content (between first and second ---)
  FRONTMATTER=$(awk 'NR==1{next} /^---/{exit} {print}' "$FILE_PATH" 2>/dev/null)
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "$FRONTMATTER" | grep -q "^${field}:"; then
      MISSING_FIELDS+=("$field")
    fi
  done
  if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
    WARNINGS+=("Missing frontmatter fields: [$(IFS=', '; echo "${MISSING_FIELDS[*]}")]")
  fi
fi

# --- OUTPUT ---
if [ ${#WARNINGS[@]} -eq 0 ]; then
  echo -e "${GREEN}✅ Doc Governance: $FILENAME — OK${NC}"
  exit 0
fi

echo -e "${YELLOW}⚠️  Doc Governance: $FILENAME${NC}"
for warning in "${WARNINGS[@]}"; do
  echo -e "${YELLOW}   • $warning${NC}"
done

# Show template if frontmatter is missing or incomplete
if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
  TODAY=$(date +%Y-%m-%d 2>/dev/null || echo "YYYY-MM-DD")
  echo -e "${YELLOW}   Template:${NC}"
  echo    "   ---"
  echo    "   title: [Document Title]"
  echo    "   version: 1.0"
  echo    "   date: $TODAY"
  echo    "   author: [AgentX/Role or User]"
  echo    "   status: Draft | Complete | Archived"
  echo    "   category: Protocol | Script | Memory | Config | Documentation | Phase"
  echo    "   ---"
fi

# Track warnings in metrics (advisory — non-blocking)
METRICS_FILE="$SCRIPT_DIR/../memory/metrics-analytics.json"
if [ -f "$METRICS_FILE" ]; then
  CURRENT=$(jq '.safetyMetrics.docValidationWarnings // 0' "$METRICS_FILE" 2>/dev/null)
  if [ -n "$CURRENT" ] && command -v jq &>/dev/null; then
    NEW=$((CURRENT + 1))
    TMP=$(mktemp)
    jq ".safetyMetrics.docValidationWarnings = $NEW" "$METRICS_FILE" > "$TMP" && mv "$TMP" "$METRICS_FILE"
  fi
fi

# Advisory mode — always exit 0 (never blocks the write)
exit 0
