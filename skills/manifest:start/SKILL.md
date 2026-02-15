---
name: manifest:start
description: Begin work on a feature. MUST be used when the user asks to implement, work on, or build a feature—even if you just created the feature or already have context.
disable-model-invocation: true
argument-hint: '[feature name or blank for next]'
---

Begin work on a feature.

**IMPORTANT:** This skill MUST be invoked whenever a user asks to implement, work on, or build a feature. This is required even if:

- You just created the feature yourself
- You already have the feature details in context
- The feature state is already 'in_progress'

The `start_feature` tool records that work is beginning and returns the authoritative spec.

## Arguments

`$ARGUMENTS` - Optional feature name to start. If blank, starts the next priority feature.

## Steps

1. Get the project for the current working directory:
   - Call `list_projects` with `directory_path` set to the current working directory
   - If no project found, tell the user to run `/manifest:init` first

2. Find the feature to start:

   **If $ARGUMENTS is provided:**
   - Call `find_features` with `project_id` and `query` set to `$ARGUMENTS`
   - If no matches, tell the user and suggest `/manifest:tree`
   - If multiple matches, list them and ask which one

   **If $ARGUMENTS is blank:**
   - First, call `get_active_feature` with the project ID
   - If a feature is focused, ask: "I see '[title]' is selected in the app. Work on this?"
   - If the user confirms, use that feature_id
   - If no focus, or the user declines, call `get_next_feature` with the project ID
   - If no feature found, tell the user there's nothing to work on

3. Start the feature:
   - Call `start_feature` with the feature ID
   - **If `start_feature` returns an error** (feature has no details):
     - Display the error message — it includes the expected spec format
     - Ask the user if they'd like to write a spec now or skip the spec gate
     - If writing a spec, use `update_feature` with `details` to add the spec, then retry `start_feature`
   - **If `start_feature` returns a warning** (details exist but lack acceptance criteria):
     - Display the warning to the user
     - Continue — this is informational, not blocking
   - **If this is a change request** (implemented feature with `desired_details`):
     - `start_feature` transitions implemented → in_progress and returns guidance
     - The response includes both `details` (current state) and `desired_details` (what's wanted)
     - Compare the two to understand what needs to change

4. **Set up git branch:**
   - Check for uncommitted changes: `git status --porcelain`
   - If there are uncommitted changes, warn the user and ask how to proceed:
     ```
     You have uncommitted changes. Should I:
     1. Stash them (can restore later with `git stash pop`)
     2. Continue anyway (changes will come with you to the new branch)
     3. Cancel so you can handle them manually
     ```
   - Check current branch: `git branch --show-current`
   - Determine base branch (usually `main` or `master`)
   - If not on base branch, switch to it: `git checkout <base>`
   - Create and checkout feature branch:
     ```bash
     git checkout -b feature/<slug>
     ```
   - Derive `<slug>` from feature title: lowercase, spaces to hyphens, remove special chars
     - Example: "OAuth Login" → `feature/oauth-login`

5. Display the result based on the feature tier (check `feature_tier` in the response):

   **For change requests (implemented feature with desired_details):**

   ```
   Started: [Title] (change request)
   State: implemented → in_progress
   Branch: feature/[slug] (created from [base branch])

   ## What Changed
   [Summary of differences between details and desired_details]

   ## Current Spec (details)
   [Current implemented state]

   ## Requested Changes (desired_details)
   [What the user wants changed]
   ```

   **For leaf features:**

   ```
   Started: [Title]
   State: [previous state] → in_progress
   Branch: feature/[slug] (created from [base branch])

   ## Feature Details
   [Feature details — this is what you're implementing]

   If details are sparse, follow the spec_guidance returned by start_feature:
   - Goal and constraints
   - Key function signatures (for interface-heavy features)
   - 1-3 examples of expected behavior (for complex logic)

   ## Ancestor Context
   [Relevant details from breadcrumb — parent conventions, project decisions]

   ## History
   [Previous work if any — check before starting fresh]
   ```

   **For feature sets (parent features):**

   ```
   Started: [Title] (feature set — [N] children)
   State: [previous state] → in_progress
   Branch: feature/[slug]

   ## Shared Context
   [This feature set's details — conventions, constraints for children]

   ## Children
   [List child features with states]
   ```

6. Remind the user:

   ```
   When you're done, use /manifest:complete to record your work.

   Tip: Commit early and often with meaningful messages.
   ```

## Important

- **Leaf features need some details before starting.** `start_feature` will refuse if a leaf feature has no `details`. Write a spec covering goal, constraints, and key interfaces using `update_feature` — follow the `spec_guidance` returned by the tool for length and structure. Parent features (those with children) are exempt.
- **Blocked features cannot be started.** `start_feature` will refuse if the feature is in the `blocked` state, or if any ancestor feature set is blocked. The error message includes which features are blocking it.
- **Do not change the feature's target version during implementation.** The version assignment is locked while work is in progress. If a feature needs to be moved to a different version, complete or pause the work first.
- **Always create a feature branch.** Never work directly on main/master.
