# Upstream Sync Workflow

This repo is a fork of [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents).

- **`main`** — clean mirror of upstream. Never commit local changes here.
- **`rob/custom`** — local additions (`link-agents.sh`, `SYNC.md`, `CLAUDE.md`). All work happens here.

## Pulling Upstream Updates

```bash
# 1. Update main from upstream
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# 2. Rebase rob/custom onto updated main
git checkout rob/custom
git rebase main
git push origin rob/custom --force-with-lease
```

## Why Rebase

The `rob/custom` branch only adds a few files on top of upstream. Rebase keeps these commits sitting cleanly on top of the latest upstream — linear history, no merge diamonds. `--force-with-lease` is safe because you're the only contributor to this branch.

## Conflict Risk

The only files unique to `rob/custom` are `link-agents.sh`, `SYNC.md`, and `CLAUDE.md`. Upstream will never touch these, so conflicts are extremely unlikely.

The one scenario that causes issues: upstream renames or removes an agent `.md` file that's in the `AGENTS` array in `link-agents.sh`. In that case, re-running `./link-agents.sh` will warn about the missing source file — just update the array entry.

## Checking for New Agents

After syncing, see what upstream added:

```bash
git diff main@{1}..main --name-only --diff-filter=A -- '*.md'
```

If any look relevant, add them to the `AGENTS` array in `link-agents.sh` and re-run.

## Re-linking After Sync

```bash
./link-agents.sh
```

This is idempotent — safe to run any time. It will warn about any agents that were renamed or removed upstream.
