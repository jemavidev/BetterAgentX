---
inclusion: auto
---

# DataLink - Document Governance Rules

**Version:** 1.0  
**Last Updated:** 2026-03-07  
**Purpose:** Ensure consistency in document creation, naming, and organization across all AgentX interactions

---

## 1. FOLDER STRUCTURE

```
DOCS/
├── 01_VISION/              # Project vision, founder profile, problem statement
├── 02_MARKET_ANALYSIS/     # Market research, competitive analysis, business model
├── 03_ARCHITECTURE/        # Technical architecture, blueprints, tech stack
├── 04_VALIDATION/          # Audits, critical reviews, risk assessments
├── 05_IMMIGRATION_RFE/     # RFE response, legal correspondence, projections
└── ARCHIVE/                # Obsolete documents (never delete, only archive)

DESIGN/ui_spike/            # UI exploration, wireframes, design prototypes
IMPLEMENTATION/             # Future code, MVP checklists, validation plans
```

---

## 2. NAMING CONVENTIONS

**Format:** `lowercase-with-hyphens.md`  
**NO dates in filenames** (use internal metadata)

✅ GOOD: `market-research.md`, `competitive-differentiation.md`  
❌ BAD: `ANALISIS_DIFERENCIADOR_DATALINK_2026-03-03.md`

---

## 3. DOCUMENT METADATA (Required)

Every document MUST start with:

```markdown
---
title: [Document Title]
version: [X.Y]
date: [YYYY-MM-DD]
author: [AgentX/Role or Founder]
status: [Draft | Complete | Archived]
category: [Vision | Market | Architecture | Validation | Legal]
---
```

---

## 4. VERSIONING

**UPDATE existing:** Minor corrections, data updates, new sections  
**CREATE new:** Major pivots, complete rewrites, consolidations

Archive old versions to `DOCS/ARCHIVE/deprecated_versions/`

---

## 5. DOCUMENT PLACEMENT

| Type | Folder |
|------|--------|
| Vision, founder profile | `01_VISION/` |
| Market, competitive, business model | `02_MARKET_ANALYSIS/` |
| Architecture, tech stack | `03_ARCHITECTURE/` |
| Audits, reviews, risks | `04_VALIDATION/` |
| RFE, legal, projections | `05_IMMIGRATION_RFE/` |
| UI, wireframes | `DESIGN/` |
| Code, MVP tasks | `IMPLEMENTATION/` |
| Obsolete docs | `DOCS/ARCHIVE/` |

---

## 6. AGENTX RESPONSIBILITIES

When creating/modifying documents:
1. ✅ Follow naming conventions (lowercase-with-hyphens.md)
2. ✅ Add metadata header
3. ✅ Place in correct folder
4. ✅ Update README.md if major document
5. ✅ Archive old versions (never delete)
6. ✅ Consolidate redundant documents
7. ✅ Maintain cross-references

---

## 7. LANGUAGE POLICY

- **Primary:** English (all technical docs, architecture, code, business documents)
- **Secondary:** Spanish (optional for Hispanic market segment communications - 19% of US small businesses)
- **Code Comments:** English only
- **User-Facing:** English (primary), Spanish (optional for Hispanic-owned business segment)

---

**Enforcement:** Auto-included in all AgentX sessions via Kiro steering
