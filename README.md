# Manifest Plugin for Claude Code

Living documentation for feature-driven product engineering. Track features as system capabilities, not work items.

## Installation

```bash
# Install the plugin
claude plugins install manifest

# Install the server (if not already installed)
brew install manifestdocs/tap/manifest
```

The plugin will detect if the server is missing on startup and guide you through installation.

## Requirements

- Claude Code 1.0.0+
- `manifest` binary in PATH (install via Homebrew)

## Commands

All commands are prefixed with `manifest:`. Type `/manifest:` and autocomplete will show available options.

### Quick Views

| Command                     | Description                                      |
| --------------------------- | ------------------------------------------------ |
| `/manifest:tree`            | Display feature hierarchy with status symbols    |
| `/manifest:versions`        | Show version roadmap (now/next/later)            |
| `/manifest:next`            | Show the highest-priority feature ready for work |
| `/manifest:feature [query]` | Search and display feature details               |

### Setup

| Command          | Description                                                            |
| ---------------- | ---------------------------------------------------------------------- |
| `/manifest:init` | Initialize Manifest for current directory (creates project + versions) |

### Workflow

| Command                     | Description                                                                              |
| --------------------------- | ---------------------------------------------------------------------------------------- |
| `/manifest:start [feature]` | **MUST** be used when implementing a feature (creates branch, defaults to next priority) |
| `/manifest:complete`        | Complete current work (commits, PR or merge, records history)                            |
| `/manifest:plan`            | Interactive feature planning session                                                     |

### Version Management

| Command                                | Description                          |
| -------------------------------------- | ------------------------------------ |
| `/manifest:release [version]`          | Mark a version as shipped            |
| `/manifest:assign [feature] [version]` | Assign a feature to a target version |

## Feature States

```
◇ proposed     - In the backlog, not yet started
○ in_progress  - Actively being worked on
● implemented  - Complete and documented
✗ deprecated   - No longer active
```

## Typical Workflow

### 0. Initialize (first time only)

```
/manifest:init
```

This creates the project, sets up versions (Now/Next/Later), and links your directory.

### 1. See what exists

```
/manifest:tree
```

### 2. Find what to work on

```
/manifest:next
```

### 3. Start work

```
/manifest:start
```

**Important:** Always use `/manifest:start` before implementing—even if you just created the feature or already have context. This records that work is beginning and returns the authoritative spec.

> **Spec gate:** `start_feature` will refuse if a leaf feature has no `details` — write a spec first using `update_feature`. If details exist but lack acceptance criteria, you'll see a warning.

### 4. Implement the feature

Work on the feature using the specification displayed by `/manifest:start`.

### 5. Complete and document

```
/manifest:complete
```

This records your work summary and links relevant commits to the feature history.

## Planning Features

Use `/manifest:plan` to interactively design a feature tree from:

- A PRD or spec document
- A description of capabilities
- Codebase analysis

Features are named by capability ("Router", "Authentication") not by task ("Implement routing"). Apply the user story test: "As a [user], I can [capability]..."

## Version Planning

Versions organize features into releases:

- **now** - First unreleased version (current focus)
- **next** - Second unreleased version (queued)
- **later** - All other unreleased versions

```
/manifest:versions          # See the roadmap
/manifest:assign Router v0.2.0   # Schedule a feature
/manifest:release v0.1.0    # Ship a version
```

## MCP Tools

The plugin also exposes MCP tools for programmatic access:

**Discovery:** `list_projects`, `find_features`, `get_feature`, `render_feature_tree`

**Setup:** `init_project`, `add_project_directory`, `plan`, `create_feature`

**Work:** `start_feature`, `complete_feature`, `get_next_feature`

**Versions:** `list_versions`, `create_version`, `set_feature_version`, `release_version`

## Philosophy

Features are **living documentation** of system capabilities, not work items to close. A feature titled "Router" should make sense years from now. Unlike JIRA/Linear where issues get resolved and archived, features in Manifest describe the current state of your product and evolve with your codebase.

## License

MIT
