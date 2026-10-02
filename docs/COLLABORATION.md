# Collaboration without Git chores

The normal workflow for either collaborator is simply:

> Open this project in Codex and describe the product change.

Codex uses `scripts/collab` to keep the main checkout as a clean testing copy,
create a separate worktree for every coding task, publish that task immediately,
checkpoint meaningful progress, validate it, open a pull request, and integrate it
after GitHub checks pass. GitHub `main` is the authoritative product state.

## Why simultaneous work is safe

Task branches have unique names containing the GitHub user, a readable task slug,
and a unique suffix. GitHub requires the `CI` check and requires each pull request
to be tested with the latest `main`. When `main` advances, a narrowly scoped
workflow asks GitHub to update open same-repository `codex/**` branches. It never
checks out or executes pull-request code with its write token. Conflicts remain in
the task worktree for Codex to reconcile semantically; the automation never picks
"ours" or "theirs" or throws work away.

Squash merging keeps `main` linear while allowing recoverable checkpoint commits
on task branches. Merged remote branches are deleted automatically.

## Recovery

Branches are pushed as soon as a task starts. `checkpoint` commits and pushes
meaningful milestones. At the next session, `start` and `doctor` show unfinished
Codex pull requests so Codex can resume them instead of creating competing work.
Unmerged branches and dirty worktrees are never removed automatically.

## Local main synchronization

`bootstrap` installs a user-level background synchronizer (a macOS LaunchAgent or
Linux systemd user timer). It only fetches, prunes remote references, and performs
a fast-forward of a clean checkout already on `main`. It does not reset, stash,
delete unknown files, install dependencies, or execute pulled project code. If the
checkout is dirty or has diverged, it stops and records the condition for Codex.

## One-time setup on the second computer

1. Accept the GitHub repository invitation and install GitHub CLI if necessary.
2. Clone the repository and open that folder in Codex.
3. Ask Codex to initialize collaboration. Codex runs `./scripts/collab bootstrap`
   and resolves any GitHub sign-in prompt.

After that, neither person needs routine Git commands. Run `./scripts/collab doctor`
only when diagnosing setup; Codex normally handles it.

## GitHub plan requirement

For a private repository, GitHub requires a plan that supports private-repository
rulesets or branch protection. The automation deliberately refuses to merge when
protection is absent. After enabling GitHub Pro (or intentionally making the
repository public), Codex runs `./scripts/collab configure-github` once; that
activates the checked-in strict ruleset and verifies it instead of weakening the
workflow.
