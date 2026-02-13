---
name: manifest:activity
description: Show recent activity timeline for the current project. Use when the user asks "what happened?", "recent activity", or "show history".
disable-model-invocation: true
---

Show recent activity across the project or for a specific feature.

## Arguments

Optional: a feature name or search term to filter activity to that feature and its descendants.

## Steps

1. Get the project for the current working directory:
   - Call `list_projects` with `directory_path` set to the current working directory
   - If no project found, tell the user to run `/manifest:init` first

2. If arguments were provided, search for the feature:
   - Call `find_features` with `project_id` and `query` set to the arguments
   - Use the first matching feature's ID as the `feature_id` filter
   - If no matches found, tell the user and fall back to project-wide activity

3. Call `get_project_history` with:
   - `project_id` from step 1
   - `feature_id` from step 2 (if applicable)
   - Default limit (20 entries)

4. Display the timeline directly in your response.
