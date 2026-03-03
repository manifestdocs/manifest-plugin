---
name: plan
description: Interactive feature planning session. Use when the user wants to plan features, break down a PRD, or design the feature tree.
disable-model-invocation: true
---

Run an interactive feature planning session using structured reasoning phases.

## Steps

### 1. Orient — Understand the project context

- Call `list_projects` with `directory_path` set to the current working directory
- If no project found, offer to run `/manifest:init` first
- If an MCP connection error occurs, the server is not running — tell the user to start it with `manifest serve`
- Call `get_project_instructions` to read the project's tech stack, conventions, and architectural decisions
- Call `render_feature_tree` to see what features already exist
- This context constrains your decomposition — don't propose features that duplicate existing ones, and respect established patterns

### 2. Gather input

Ask the user what they want to plan:

```
What would you like to plan?

Options:
- Paste a PRD, spec, or feature description
- Describe the capabilities you want to add
- Say "analyze" to let me examine the codebase
```

**If the user says "analyze":**
- Call `generate_feature_tree` with `directory_path` set to the current working directory
- This scans git history and code structure to discover existing capabilities
- Use the returned markdown as input for the analysis phases below
- Tell the user: "Analyzed codebase. Found [N] capability areas. Proposing feature tree..."

### 3. Analyze — Structured reasoning before designing

Work through these phases in order. Do your reasoning internally, but surface the results.

**Phase A: Extract explicit capabilities.**
Read the input and list every capability the user explicitly described. These are the "happy path" features — what the user knows they want.

**Phase B: Infer implied capabilities.**
This is the critical step. For each explicit capability, ask: "What else must the system be able to do for this to work?" Look for:
- Capabilities the user assumes exist but didn't mention (e.g., "user uploads a file" implies the system can store and serve files)
- Cross-cutting concerns that apply to multiple features (e.g., authorization, validation, error handling) — these belong in parent-level context, not as separate features
- Enabling capabilities that must exist first (e.g., "invite a team member" implies user management exists)

Important: Inferred items should be *capabilities*, not implementation tasks. "File Storage" is a capability. "Configure S3 bucket" is a task — put that in the feature's spec, not as a separate feature.

**Phase C: Flag ambiguity.**
Scan for anything that is vague, subjective, or underspecified. Collect these as clarification questions. Common triggers:
- Subjective terms: "fast", "seamless", "robust", "intuitive" — what does the user actually mean?
- Unstated scope: "social login" — which providers? "notifications" — email, push, in-app?
- Missing constraints: no mention of performance requirements, data limits, or supported platforms
- Contradictions or tensions between stated requirements

Don't guess at answers. Collect them for the user.

### 4. Design the feature tree

Now structure your analysis into a feature tree:
- Apply the user story test to each leaf: "As a [user], I can [capability]..."
- Name features by capability (e.g., "Router" not "Implement routing")
- Group related features under parent nodes
- Assign priorities (lower = implement first)
- **Write tier-appropriate details:**
  - Parent features: shared architectural context, patterns, constraints for children
  - Leaf features: focused specification (50-150 words) with this structure:
    1. **User story** opening line: "As a [user], I can [capability] so that [benefit]."
    2. Brief context (1-2 sentences): key behavior, constraints, or edge cases.
    3. **Acceptance criteria** as checkbox items (3-5): concrete assertions verifiable in specs and tests.
  - Write what agents cannot discover from code (business rules, edge cases, product intent). Do NOT include file paths, directory layouts, or implementation approach.
  - **Never repeat the feature title in the details** — the title is displayed separately in the UI

  Example of a good leaf spec:

  > As a user, I can mark a todo as complete so that I can track my progress.
  >
  > Tapping the checkbox next to a todo toggles its completed state. Completed todos display with strikethrough styling.
  >
  > - [ ] Checkbox appears to the left of each todo item
  > - [ ] Clicking the checkbox toggles the `completed` boolean
  > - [ ] Completed todos render with line-through text decoration
  > - [ ] Toggling is immediate — no confirmation dialog

- Parent details flow to all children via breadcrumb — put shared decisions there, not in every leaf

### 5. Present the proposal

Call `plan` with `confirm: false` to get a preview.

Display the proposed tree, then any clarification questions:

```
Proposed Feature Tree:

◇ [Parent Feature]
│  [Description]
├── ◇ [Child Feature 1] (priority: 1)
│      [Description]
└── ◇ [Child Feature 2] (priority: 2)
        [Description]

Clarification needed:
- [Question about vague/missing requirement]
- [Question about unstated scope]

These questions won't block creation, but answering them will
improve the specs. Want to address them now, or create as-is
and refine later?
```

If there are no clarification questions, skip that section.

### 6. Iterate or confirm

- If user answers clarification questions, update the relevant feature specs and re-present
- If user wants structural changes, modify and re-present
- If user approves, call `plan` with `confirm: true`

### 7. Distill the root feature

After creating child features, the source PRD/spec content should NOT remain verbatim on the root. The detailed content has been distributed to children — the root should now hold only high-level project context.

Call `update_feature` on the project's root feature to replace its details with:
- Project overview (1-2 sentences)
- Tech stack and key dependencies
- Architectural decisions and conventions
- Any cross-cutting constraints

Also provide `details_summary` (~200 words) so breadcrumbs stay concise.

If the root feature had no details (PRD was pasted directly), write project-level context based on what you learned during analysis. If the root already had appropriate high-level content (not a PRD), skip this step.

### 8. Create versions and distribute features

Features should be organized into shippable increments, not dumped into a single version:

1. Create semantic versions with `create_version` (e.g., 0.1.0, 0.2.0, 0.3.0)
2. Assign features to versions using `set_feature_version`, grouping by delivery phase:
   - **0.1.0**: Foundational features — project setup, core models, basic CRUD
   - **0.2.0**: Features that build on 0.1.0 — validation, relationships, business logic
   - **0.3.0+**: Advanced features — optimization, integrations, polish
3. Each version should be a shippable increment — avoid splitting tightly-coupled features across versions
4. Features with dependencies should land in the same version or in order (dependency first)

### 9. Display result

```
Created [N] features across [M] versions.

Use /manifest:versions to see the release roadmap.
Use /manifest:tree to see the full hierarchy.
Use /manifest:start to begin work on the first feature.
```
