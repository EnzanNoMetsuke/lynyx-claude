# Feature List Schema

This document defines the JSON schema for `feature_list.json`, the source of truth for auto-coder project state.

## File Location

```text
<project-root>/
└── .auto-coder/
    └── feature_list.json
```

## Complete Schema

```json
{
  "project": {
    "name": "string",
    "prefix": "string (e.g., MYAPP)",
    "spec_file": "string (path to spec)",
    "created_at": "ISO8601 timestamp",
    "last_updated": "ISO8601 timestamp"
  },
  "features": [
    {
      "id": "number (1-indexed, sequential)",
      "task_id": "string (e.g., MYAPP-001)",
      "category": "functional | style | non-functional",
      "priority": "high | medium | low",
      "description": "string (brief feature description)",
      "steps": [
        "Step 1: description of first test step",
        "Step 2: description of second test step"
      ],
      "passes": "boolean (false initially, true when complete)",
      "completed_at": "ISO8601 timestamp | null",
      "commit_hash": "string | null"
    }
  ],
  "summary": {
    "total": "number",
    "completed": "number",
    "remaining": "number",
    "by_priority": {
      "high": { "total": "number", "completed": "number" },
      "medium": { "total": "number", "completed": "number" },
      "low": { "total": "number", "completed": "number" }
    }
  }
}
```

## Field Descriptions

### Project Section

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable project name |
| `prefix` | string | Short prefix for task IDs (e.g., `MYAPP`, `AUTH`, `API`) |
| `spec_file` | string | Path to the specification file used to generate features |
| `created_at` | ISO8601 | Timestamp when feature_list.json was created |
| `last_updated` | ISO8601 | Timestamp of most recent modification |

### Feature Entry

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Sequential identifier (1, 2, 3...) |
| `task_id` | string | Unique task ID in format `{PREFIX}-{PADDED_NUMBER}` |
| `category` | enum | One of: `functional`, `style`, `non-functional` |
| `priority` | enum | One of: `high`, `medium`, `low` |
| `description` | string | Brief description of what the feature does |
| `steps` | array | Test steps, each prefixed with "Step N: " |
| `passes` | boolean | `false` until all tests pass, then `true` |
| `completed_at` | string/null | ISO8601 timestamp when marked complete |
| `commit_hash` | string/null | Git commit hash that completed this feature |

### Summary Section

Aggregated statistics for quick progress assessment. Must be recalculated whenever `passes` changes.

## Task ID Format

Task IDs follow the pattern: `{PREFIX}-{PADDED_NUMBER}`

- **PREFIX**: Auto-generated from project name, presented to user for approval
  - Example: "My Web App" → `MWA` or `MYWEBAPP`
- **PADDED_NUMBER**: Zero-padded to 3 digits (001, 002, ... 999)
- **Examples**: `MYAPP-001`, `AUTH-042`, `API-123`

## Step Format

Each step in the `steps` array must be prefixed with its sequential number:

```json
"steps": [
  "Step 1: User can navigate to /login page",
  "Step 2: Login form displays email and password fields",
  "Step 3: Invalid credentials show error message",
  "Step 4: Valid credentials redirect to dashboard",
  "Step 5: Session persists across page refreshes"
]
```

- Numbering starts at 1 for each feature
- Numbering is sequential within each feature
- Steps should be concrete and testable

## Example

```json
{
  "project": {
    "name": "My Web App",
    "prefix": "MWA",
    "spec_file": "SPEC.txt",
    "created_at": "2026-01-07T10:00:00Z",
    "last_updated": "2026-01-07T14:30:00Z"
  },
  "features": [
    {
      "id": 1,
      "task_id": "MWA-001",
      "category": "functional",
      "priority": "high",
      "description": "User authentication with email/password",
      "steps": [
        "Step 1: User can navigate to /login page",
        "Step 2: Login form displays email and password fields",
        "Step 3: Invalid credentials show error message",
        "Step 4: Valid credentials redirect to dashboard",
        "Step 5: Session persists across page refreshes"
      ],
      "passes": true,
      "completed_at": "2026-01-07T11:45:00Z",
      "commit_hash": "a1b2c3d"
    },
    {
      "id": 2,
      "task_id": "MWA-002",
      "category": "functional",
      "priority": "high",
      "description": "User registration flow",
      "steps": [
        "Step 1: User can navigate to /register page",
        "Step 2: Registration form validates email format",
        "Step 3: Password strength requirements enforced",
        "Step 4: Successful registration creates account",
        "Step 5: User redirected to login after registration"
      ],
      "passes": false,
      "completed_at": null,
      "commit_hash": null
    },
    {
      "id": 3,
      "task_id": "MWA-003",
      "category": "style",
      "priority": "medium",
      "description": "Responsive navigation bar",
      "steps": [
        "Step 1: Navigation bar displays on all pages",
        "Step 2: Logo links to home page",
        "Step 3: Menu collapses to hamburger on mobile",
        "Step 4: Hamburger menu opens/closes on tap"
      ],
      "passes": false,
      "completed_at": null,
      "commit_hash": null
    }
  ],
  "summary": {
    "total": 3,
    "completed": 1,
    "remaining": 2,
    "by_priority": {
      "high": { "total": 2, "completed": 1 },
      "medium": { "total": 1, "completed": 0 },
      "low": { "total": 0, "completed": 0 }
    }
  }
}
```

## Immutability Rules

These rules ensure data integrity across sessions:

### Can Modify (One-Time Only)

| Field | Rule |
|-------|------|
| `passes` | Can change `false` → `true` only (never back to false) |
| `completed_at` | Can set once when empty (null → timestamp) |
| `commit_hash` | Can set once when empty (null → hash) |

### Always Recalculated

| Field | Rule |
|-------|------|
| `summary.*` | Recalculate whenever any `passes` field changes |
| `project.last_updated` | Update to current timestamp on any modification |

### Immutable After Creation

| Field | Rule |
|-------|------|
| `project.name` | Never modify |
| `project.prefix` | Never modify |
| `project.spec_file` | Never modify |
| `project.created_at` | Never modify |
| `id` | Never modify |
| `task_id` | Never modify |
| `category` | Never modify |
| `priority` | Never modify |
| `description` | Never modify |
| `steps` | Never modify |

### Never Delete

- Never remove any feature entry from the `features` array
- Never remove any step from a feature's `steps` array
