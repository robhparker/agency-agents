# CLAUDE.md — agency-agents

## What This Repo Is

Fork of [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — a collection of 177+ specialized AI agent personalities ("The Agency"). This fork adds a selective symlink system to install only relevant agents into Claude Code.

## Branch Strategy

| Branch | Purpose | Rules |
|--------|---------|-------|
| `main` | Clean upstream mirror | Never commit here. Only `git merge upstream/main`. |
| `rob/custom` | Local additions | All local files live here. Rebase onto `main` after upstream sync. |

## Local-Only Files

These files exist only on `rob/custom` and are never in upstream:

- **`link-agents.sh`** — Symlinks selected agent `.md` files into `~/.claude/agents/`
- **`SYNC.md`** — Upstream sync workflow documentation
- **`CLAUDE.md`** — This file

## How Agents Are Installed

```bash
./link-agents.sh           # Create symlinks (idempotent)
./link-agents.sh --dry-run # Preview without changes
./link-agents.sh --unlink  # Remove symlinks only
```

Symlinks point from `~/.claude/agents/<agent>.md` to the repo checkout. Edits in the repo are immediately reflected — no re-copy needed.

## Safety Invariant

The script **never overwrites regular (non-symlink) files** in `~/.claude/agents/`. This protects GSD agents (`gsd-*.md`) and any other agents installed separately.

## Adding or Removing Agents

1. Edit the `AGENTS` array in `link-agents.sh`
2. Re-run `./link-agents.sh`

The full inventory of available agents is in the repo's category directories: `engineering/`, `specialized/`, `testing/`, `support/`, `project-management/`, `product/`, `sales/`, `design/`, `marketing/`, `academic/`, `game-development/`, `paid-media/`, `spatial-computing/`, `strategy/`.

## Syncing Upstream

Follow the workflow in `SYNC.md`:

```bash
git checkout main && git fetch upstream && git merge upstream/main && git push origin main
git checkout rob/custom && git rebase main && git push origin rob/custom --force-with-lease
./link-agents.sh   # catches renamed/removed agents
```

## Owner Context

Rob Parker — Solutions Engineer at an MSP. Tech stack:

- **Web:** WordPress/WooCommerce/YOOtheme Pro development
- **CRM:** GoHighLevel implementations
- **Automation:** n8n workflow automation
- **Backend:** Python/Go/TypeScript (marine dealership ERP with TanStack Start/Hono on Bun/PostgreSQL)
- **Infrastructure:** Docker/Dokploy container management, Proxmox homelab
- **AI:** Park Place/OpenClaw multi-agent architecture

## Currently Selected Agents (29)

The `AGENTS` array in `link-agents.sh` contains 29 agents selected for relevance to the above stack, spanning engineering, specialized, testing, support, project management, product, sales, and design categories.

## Key Directories

| Path | Contents |
|------|----------|
| `~/.claude/agents/` | Target for symlinks. Also contains GSD agents (regular files — do not touch). |
| `engineering/` | Backend, frontend, DevOps, security, AI, CMS agents |
| `specialized/` | Workflow architect, automation governance, MCP builder, orchestrator |
| `scripts/` | Upstream's install/convert/lint scripts (not used by our symlink approach) |
