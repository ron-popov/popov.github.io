#!/usr/bin/env bash
# Build the site with Zola and publish public/ to the gh-pages branch.
#
# public/ is a git worktree checked out to gh-pages (kept out of main's
# .gitignore'd tracking). Each run rebuilds the site and commits only the
# contents of public/ to that branch.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_DIR="$REPO_ROOT/public"
BRANCH="gh-pages"
REMOTE="origin"

cd "$REPO_ROOT"

# Ensure public/ is a worktree tracking the gh-pages branch.
if [ ! -f "$PUBLIC_DIR/.git" ]; then
  rm -rf "$PUBLIC_DIR"
  git fetch "$REMOTE" "$BRANCH" 2>/dev/null || true
  if git show-ref --verify --quiet "refs/remotes/$REMOTE/$BRANCH"; then
    git worktree add "$PUBLIC_DIR" "$BRANCH"
  else
    git worktree add --orphan -b "$BRANCH" "$PUBLIC_DIR"
    (cd "$PUBLIC_DIR" && git commit --allow-empty -m "Initialize gh-pages branch")
  fi
fi

echo "Building site with zola..."
zola build

cd "$PUBLIC_DIR"
git add -A

if git diff --cached --quiet; then
  echo "No changes to publish."
  exit 0
fi

git commit -m "Deploy site $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git push "$REMOTE" "$BRANCH"

echo "Deployed to $BRANCH."
