# 📊 Memory Dashboard - Architecture and Design

## 🎯 Concept

The Memory Dashboard is an **all-in-one HTML file** that lets you visualize and manage the project's JSON memory files without external scripts or Python dependencies.

## 🏗️ Architecture

### All-in-One Design

```
dashboard.html
├── HTML Structure
├── CSS Styles (embedded)
├── JavaScript Logic (embedded)
└── No external dependencies
```

**Advantages:**
- ✅ No external dependencies
- ✅ Works offline
- ✅ Portable (single file)
- ✅ Easy to distribute
- ✅ No web server required

## 🔧 Functionality

### 1. Reading JSON Files

The dashboard reads JSON files directly using:

```javascript
// Option A: File API (user selects files)
const fileInput = document.createElement('input');
fileInput.type = 'file';
fileInput.accept = '.json';
fileInput.onchange = (e) => {
  const file = e.target.files[0];
  const reader = new FileReader();
  reader.onload = (event) => {
    const data = JSON.parse(event.target.result);
    // Process data
  };
  reader.readAsText(file);
};

// Option B: Drag & Drop
dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  const file = e.dataTransfer.files[0];
  // Read file
});
```

### 2. CRUD Operations

#### Create
```javascript
function createEntry(type, data) {
  const memoryData = loadMemoryData(type);
  const newEntry = {
    id: generateId(),
    date: new Date().toISOString(),
    ...data
  };
  memoryData.push(newEntry);
  saveMemoryData(type, memoryData);
}
```

#### Read
```javascript
function readEntries(type, filter = null) {
  const memoryData = loadMemoryData(type);
  if (filter) {
    return memoryData.filter(filter);
  }
  return memoryData;
}
```

#### Update
```javascript
function updateEntry(type, id, updates) {
  const memoryData = loadMemoryData(type);
  const index = memoryData.findIndex(e => e.id === id);
  if (index !== -1) {
    memoryData[index] = { ...memoryData[index], ...updates };
    saveMemoryData(type, memoryData);
  }
}
```

#### Delete
```javascript
function deleteEntry(type, id) {
  const memoryData = loadMemoryData(type);
  const filtered = memoryData.filter(e => e.id !== id);
  saveMemoryData(type, filtered);
}
```

### 3. Data Persistence

**Two strategies:**

#### Strategy A: LocalStorage (Temporary)
```javascript
// Save in browser
function saveToLocalStorage(type, data) {
  localStorage.setItem(`memory_${type}`, JSON.stringify(data));
}

// Load from browser
function loadFromLocalStorage(type) {
  const data = localStorage.getItem(`memory_${type}`);
  return data ? JSON.parse(data) : [];
}
```

**Advantages:**
- Fast
- No permissions required
- Works offline

**Disadvantages:**
- Data only in the browser
- Does not sync with JSON files

#### Strategy B: File System Access API (Recommended)
```javascript
// Request directory access
async function requestDirectoryAccess() {
  const dirHandle = await window.showDirectoryPicker();
  return dirHandle;
}

// Read JSON file
async function readJSONFile(dirHandle, filename) {
  const fileHandle = await dirHandle.getFileHandle(filename);
  const file = await fileHandle.getFile();
  const text = await file.text();
  return JSON.parse(text);
}

// Write JSON file
async function writeJSONFile(dirHandle, filename, data) {
  const fileHandle = await dirHandle.getFileHandle(filename, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(JSON.stringify(data, null, 2));
  await writable.close();
}
```

**Advantages:**
- ✅ Real sync with files
- ✅ Changes persist to disk
- ✅ Multiple users can see changes
- ✅ Git compatible

**Disadvantages:**
- Requires user permissions
- Only works in modern browsers (Chrome, Edge)

## 🎨 User Interface

### Main Components

```
┌─────────────────────────────────────────┐
│  Header: BetterAgentX Memory Dashboard  │
├─────────────────────────────────────────┤
│  [Tabs: Context | Decisions | Progress] │
├─────────────────────────────────────────┤
│  Search: [___________] [Filter ▼]       │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │  Entry Card                       │  │
│  │  ─────────────────────────────    │  │
│  │  Title: Decision #001             │  │
│  │  Date: 2026-02-14                 │  │
│  │  [Edit] [Delete]                  │  │
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│  [+ New Entry]                          │
└─────────────────────────────────────────┘
```

### Tabs

1. **Overview** - General statistics
2. **Active Context** - Current project context
3. **Decisions** - Technical decision log
4. **Progress** - Tasks and progress
5. **Patterns** - Identified patterns
6. **Timeline** - Chronological view

## 🔄 Workflow

### Initial Flow (First Time)

```
1. User opens dashboard.html
2. Dashboard requests access to .claude/memory/
3. User grants permission
4. Dashboard reads all JSON files
5. Displays data in the interface
```

### Edit Flow

```
1. User clicks "Edit"
2. Modal opens with form
3. User modifies data
4. User clicks "Save"
5. Dashboard updates JSON file
6. Interface refreshes automatically
```

### Create Flow

```
1. User clicks "+ New Entry"
2. Modal opens with empty form
3. User fills in data
4. User clicks "Create"
5. Dashboard adds entry to JSON
6. Dashboard saves file
7. New entry appears in list
```

## 🚫 Why We Don't Need sync-memory.py

### Original Problem

The concept of `sync-memory.py` was:
```
.md files (readable) ↔ sync-memory.py ↔ JSON (for dashboard)
```

### Current Solution

With native JSON files:
```
.json files ↔ HTML Dashboard (direct read/write)
```

**Advantages:**
- ✅ No Python dependency
- ✅ No manual sync step
- ✅ Real-time changes
- ✅ Less complexity
- ✅ Fewer failure points

## 🔐 Security and Permissions

### File System Access API

```javascript
// Request permission once
const dirHandle = await window.showDirectoryPicker();

// Verify permission before each operation
const permission = await dirHandle.queryPermission({ mode: 'readwrite' });
if (permission !== 'granted') {
  await dirHandle.requestPermission({ mode: 'readwrite' });
}
```

### Data Validation

```javascript
function validateEntry(type, data) {
  const schemas = {
    decision: {
      required: ['id', 'date', 'title', 'decision'],
      optional: ['context', 'consequences', 'alternatives']
    },
    progress: {
      required: ['id', 'date', 'title', 'status'],
      optional: ['priority', 'agent', 'blockers']
    }
  };

  const schema = schemas[type];
  for (const field of schema.required) {
    if (!data[field]) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  return true;
}
```

## 📱 Responsive Design

```css
/* Mobile First */
.dashboard {
  padding: 1rem;
}

/* Tablet */
@media (min-width: 768px) {
  .dashboard {
    padding: 2rem;
    max-width: 720px;
    margin: 0 auto;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .dashboard {
    max-width: 1200px;
    display: grid;
    grid-template-columns: 250px 1fr;
  }
}
```

## 🎯 Advanced Features

### 1. Real-Time Search

```javascript
function searchEntries(query) {
  const allEntries = getAllEntries();
  return allEntries.filter(entry => {
    const searchText = JSON.stringify(entry).toLowerCase();
    return searchText.includes(query.toLowerCase());
  });
}
```

### 2. Filters

```javascript
function filterByDate(entries, startDate, endDate) {
  return entries.filter(e => {
    const date = new Date(e.date);
    return date >= startDate && date <= endDate;
  });
}

function filterByAgent(entries, agent) {
  return entries.filter(e => e.agent === agent);
}
```

### 3. Export/Import

```javascript
// Export all
function exportAll() {
  const data = {
    context: loadMemoryData('context'),
    decisions: loadMemoryData('decisions'),
    progress: loadMemoryData('progress'),
    patterns: loadMemoryData('patterns')
  };

  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json'
  });

  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `memory-backup-${Date.now()}.json`;
  a.click();
}

// Import
function importData(file) {
  const reader = new FileReader();
  reader.onload = (e) => {
    const data = JSON.parse(e.target.result);
    // Restore data
  };
  reader.readAsText(file);
}
```

## 🔄 Git Compatibility

JSON files are Git-friendly:

```bash
# View changes
git diff .claude/memory/decision-log.json

# Commit changes
git add .claude/memory/*.json
git commit -m "docs: update memory - added decision #005"
```

## 📊 Statistics

```javascript
function calculateStats() {
  return {
    totalDecisions: loadMemoryData('decisions').length,
    totalTasks: loadMemoryData('progress').length,
    completedTasks: loadMemoryData('progress')
      .filter(t => t.status === 'completed').length,
    totalPatterns: loadMemoryData('patterns').length,
    lastUpdate: getLastUpdateDate()
  };
}
```

## 🎨 Themes (Dark/Light Mode)

```javascript
function toggleTheme() {
  const currentTheme = document.body.dataset.theme || 'light';
  const newTheme = currentTheme === 'light' ? 'dark' : 'light';
  document.body.dataset.theme = newTheme;
  localStorage.setItem('theme', newTheme);
}
```

## 🚀 Next Steps

To implement the dashboard:

1. **Design HTML structure** - Layout and components
2. **Implement File System Access API** - JSON read/write
3. **Create CRUD operations** - Create, Read, Update, Delete
4. **Add search and filters** - Improved UX
5. **Implement validation** - Consistent data
6. **Add export/import** - Backup and restore
7. **Testing** - Verify in different browsers

---

**Version:** 2.1.0
**Last Updated:** 2026-02-14
**Status:** Design Document (Implementation Pending)
