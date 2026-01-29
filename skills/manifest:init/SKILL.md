---
name: manifest:init
description: Initialize Manifest for the current project. Sets up project, versions, and optionally imports existing features.
disable-model-invocation: true
---

Initialize Manifest for a new or existing codebase.

## Steps

1. **Check if already initialized:**
   - Call `list_projects` with `directory_path` set to the current working directory
   - If a project is found, tell the user:
     ```
     This directory is already linked to project "[Name]".
     Use /manifest:tree to see features or /manifest:plan to add new ones.
     ```
   - Exit early if already initialized

2. **Analyze the codebase:**
   - Call `init_project` with `directory_path` set to the current working directory
   - This creates the project and links the directory

3. **Determine if this is a new or existing codebase:**
   - Check the analysis results for existing code/commits
   - Ask the user:
     ```
     Is this:
     1. A new project (starting fresh)
     2. An existing codebase (has features already built)
     ```

4. **Ask for version naming:**
   ```
   What version are you working toward?

   Examples:
   - "0.1.0" or "v0.1.0" (semantic versioning)
   - "1.0" (simple numbering)
   - "MVP" or "Beta" (milestone names)

   This will be your "Now" version - the current focus.
   ```

5. **Create default versions:**

   **For new projects (3 versions):**
   - Create versions in this order (order matters for Now/Next/Later):
     1. `[user input]` - "Now" (current focus)
     2. `[next version]` - "Next" (e.g., if user said "0.1.0", create "0.2.0")
     3. `Backlog` - "Later" (catch-all for future ideas)

   **For existing codebases (4 versions):**
   - Ask: "What version represents the features already built?"
     - Suggest: `v0.0.x` or `Shipped` or `Legacy`
   - Create versions in order:
     1. `[existing version]` - For already-implemented features (mark as released immediately)
     2. `[user input]` - "Now" (current focus)
     3. `[next version]` - "Next"
     4. `Backlog` - "Later"

6. **Display summary:**
   ```
   Project initialized: [Name]

   Versions created:
   [If existing]: ✓ [existing] (released) - for existing features
   ◇ [now] (Now) - current focus
   ◇ [next] (Next) - up next
   ◇ Backlog (Later) - future ideas

   Next steps:
   - /manifest:plan to design your feature tree
   - /manifest:tree to see what exists
   ```

## Version Naming Helpers

When creating the "Next" version, apply these heuristics:
- `0.1.0` → `0.2.0`
- `1.0` → `1.1`
- `v1` → `v2`
- `MVP` → `Post-MVP`
- `Beta` → `v1.0`
- If unsure, ask the user

## Notes

- The first unreleased version becomes "Now" (current focus)
- The second unreleased version becomes "Next"
- Order matters: create versions in chronological order
- For existing codebases, the "existing features" version should be released immediately so it doesn't show as "Now"
