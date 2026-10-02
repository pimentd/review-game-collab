# Project guidance

This is a fresh product repository. Do not choose a framework until the product
requires one. Keep secrets and machine-local state out of Git.

## Collaboration

- Treat `origin/main` as the canonical integrated product and keep the primary
  checkout clean on `main` for local testing.
- Before repository-changing work, run `./scripts/collab bootstrap` when needed,
  then use `./scripts/collab start "task description"`. Work only in the isolated
  worktree it creates from the latest `origin/main`.
- Codex owns routine fetch, branch, checkpoint, push, PR, update, merge, sync, and
  cleanup mechanics. Use `./scripts/collab checkpoint` during substantial work
  and `./scripts/collab finish` before reporting a coding task complete.
- Preserve collaborators' work. Never force-push routine work, bypass protection,
  discard conflicts, or delete unmerged branches with unique commits.
- Run the relevant checks for the chosen stack. `./scripts/collab ci` is the
  repository-level verification entry point and must remain current as the app
  evolves.

Human-facing architecture and recovery behavior are in `docs/COLLABORATION.md`.
