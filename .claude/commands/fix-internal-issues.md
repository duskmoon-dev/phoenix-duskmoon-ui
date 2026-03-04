# Fix Internal Request Issues

Find all open GitHub issues labeled `internal request` and **without** the label `unable to resolve`, then fix each one in an isolated git worktree and open a PR.

## Execution Flow

### 1. List Issues

Use the GitHub MCP tool to list open issues with the label `internal request`:

```
owner: duskmoon-dev
repo: phoenix-duskmoon-ui
labels: ["internal request"]
state: open
```

Filter out any issues that also have the label `unable to resolve`.

If no actionable issues remain, report "No open internal request issues" and stop.

Print a summary table of all found issues (number, title, labels).

### 2. Fix Each Issue

For **each** issue, perform these steps sequentially:

#### 2a. Create a worktree branch

```bash
# Branch name: fix/issue-{number}
git worktree add .trees/issue-{number} -b fix/issue-{number} main
```

If the `.trees/` directory doesn't exist, create it first. If the branch or worktree already exists, remove and recreate it.

#### 2b. Understand the issue

Read the issue body carefully. Identify:
- What files need to change
- The expected fix
- Any reproduction steps or error messages

#### 2c. Implement the fix

Work **inside the worktree directory** (`.trees/issue-{number}/`):
- Make the minimum changes needed to fix the issue
- Run `bun run build:core` to verify the build passes
- Run `cd packages/core && bun test tests/unit` to verify tests pass
- If the fix requires new tests, add them

#### 2d. Commit and push

```bash
# Stage and commit inside the worktree
cd .trees/issue-{number}
git add -A
git commit -m "fix: {concise description} (fixes #{number})"
git push origin fix/issue-{number}
```

#### 2e. Create a Pull Request

Use `gh pr create` or GitHub MCP tool:
- **Title**: `fix: {concise description}`
- **Base**: `main`
- **Head**: `fix/issue-{number}`
- **Labels**: `internal request fixed`
- **Body**:
  ```
  ## Summary
  - {1-2 bullet points describing the fix}

  Fixes #{number}
  ```

Ensure the label `internal request fixed` exists. If it doesn't, create it first:
```bash
gh label create "internal request fixed" --color "0e8a16" --description "Fixed via automated internal request workflow"
```

#### 2f. Clean up worktree

```bash
cd {original_repo_root}
git worktree remove .trees/issue-{number}
git branch -d fix/issue-{number}  # local branch cleanup (remote stays for PR)
```

### 3. Summary

After processing all issues, output a summary:

```
Internal Request Issues Processed:
  #19 — Missing cascader export → PR #XX (fix/issue-19)
  #20 — Button hover broken   → PR #XX (fix/issue-20)

Created PRs: 2
Skipped: 0
Failed: 0
```

If any issue could not be fixed automatically (too complex, unclear requirements, outside this repo's scope):
1. Add the label `unable to resolve` to the issue
2. Post a comment explaining why the issue could not be resolved automatically
3. Report it as skipped in the summary with the reason

Ensure the label `unable to resolve` exists. If it doesn't, create it first:
```bash
gh label create "unable to resolve" --color "e4e669" --description "Cannot be resolved automatically"
```

## Important Notes

- Always work in worktrees — never modify the main working directory
- Each issue gets its own branch and PR
- Run build and tests before committing — do not push broken code
- Use conventional commit messages with `fixes #{number}` to auto-close issues on merge
- If an issue is already being worked on (has an open PR), skip it
