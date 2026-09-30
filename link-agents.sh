#!/usr/bin/env bash
set -euo pipefail

# Selective agent symlinker for Claude Code
# Symlinks chosen agent .md files from this repo into ~/.claude/agents/
# Safe: never overwrites regular (non-symlink) files (protects GSD agents etc.)

# ── Colors ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  ⚠${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; }
info() { printf "${CYAN}  →${NC} %s\n" "$1"; }

# ── Paths ───────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.claude/agents"

# ── Agent selection ─────────────────────────────────────────────────────────────
# Edit this array to add/remove agents. Paths are relative to repo root.
AGENTS=(
  # Engineering
  engineering/engineering-backend-architect.md
  engineering/engineering-cms-developer.md
  engineering/engineering-devops-automator.md
  engineering/engineering-database-optimizer.md
  engineering/engineering-frontend-developer.md
  engineering/engineering-software-architect.md
  engineering/engineering-code-reviewer.md
  security/security-architect.md
  engineering/engineering-ai-engineer.md
  engineering/engineering-sre.md
  engineering/engineering-rapid-prototyper.md
  engineering/engineering-technical-writer.md
  engineering/engineering-git-workflow-master.md
  engineering/engineering-senior-developer.md

  # Specialized
  specialized/specialized-workflow-architect.md
  specialized/automation-governance-architect.md
  specialized/specialized-mcp-builder.md
  specialized/agents-orchestrator.md
  specialized/specialized-developer-advocate.md
  specialized/specialized-document-generator.md

  # Testing
  testing/testing-api-tester.md
  testing/testing-workflow-optimizer.md

  # Support
  support/support-infrastructure-maintainer.md

  # Project Management
  project-management/project-manager-senior.md

  # Product
  product/product-manager.md

  # Sales
  sales/sales-engineer.md
  sales/sales-proposal-strategist.md

  # Design
  design/design-ux-architect.md
  design/design-ui-designer.md

  # Marketing
  marketing/marketing-seo-specialist.md

  # Security
  security/security-appsec-engineer.md

  # Paid Media
  paid-media/paid-media-tracking-specialist.md
  paid-media/paid-media-search-query-analyst.md
  paid-media/paid-media-creative-strategist.md
  paid-media/paid-media-ppc-strategist.md
  paid-media/paid-media-auditor.md
  paid-media/paid-media-paid-social-strategist.md
)

# ── Usage ───────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}Usage:${NC} $(basename "$0") [OPTIONS]

Symlinks selected Agency agent .md files into ~/.claude/agents/

${BOLD}Options:${NC}
  --dry-run   Show what would be done without making changes
  --unlink    Remove symlinks created by this script (leaves regular files alone)
  --help, -h  Show this help message

${BOLD}Safety:${NC}
  Regular files in ~/.claude/agents/ are never overwritten (e.g. GSD agents).
  Only symlinks are created or removed.

${BOLD}To add/remove agents:${NC}
  Edit the AGENTS array in this script, then re-run.
EOF
}

# ── Flag parsing ────────────────────────────────────────────────────────────────
DRY_RUN=false
UNLINK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)  DRY_RUN=true; shift ;;
    --unlink)   UNLINK=true; shift ;;
    --help|-h)  usage; exit 0 ;;
    *)          err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# ── Main logic ──────────────────────────────────────────────────────────────────
if $UNLINK; then
  printf "\n${BOLD}Unlinking agents from ${DEST_DIR}${NC}\n\n"
  removed=0
  for agent in "${AGENTS[@]}"; do
    name="$(basename "$agent")"
    dest="${DEST_DIR}/${name}"
    if [[ -L "$dest" ]]; then
      if $DRY_RUN; then
        info "Would remove symlink: $name"
      else
        rm "$dest"
        ok "Removed: $name"
      fi
      (( removed++ )) || true
    fi
  done
  printf "\n${BOLD}Done.${NC} ${removed} symlink(s) %s.\n" "$($DRY_RUN && echo 'would be removed' || echo 'removed')"
  exit 0
fi

# Default: link mode
printf "\n${BOLD}Linking agents into ${DEST_DIR}${NC}\n\n"
mkdir -p "$DEST_DIR"

linked=0
skipped=0

for agent in "${AGENTS[@]}"; do
  src="${REPO_ROOT}/${agent}"
  name="$(basename "$agent")"
  dest="${DEST_DIR}/${name}"

  # Source must exist
  if [[ ! -f "$src" ]]; then
    warn "Source not found, skipping: $agent"
    (( skipped++ )) || true
    continue
  fi

  # Never clobber a regular (non-symlink) file
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    warn "Regular file exists, refusing to overwrite: $name"
    (( skipped++ )) || true
    continue
  fi

  if $DRY_RUN; then
    info "Would link: $name -> $src"
  else
    ln -sf "$src" "$dest"
    ok "Linked: $name"
  fi
  (( linked++ )) || true
done

printf "\n${BOLD}Done.${NC} ${linked} %s, ${skipped} skipped.\n" "$($DRY_RUN && echo 'would be linked' || echo 'linked')"
