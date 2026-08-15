#!/bin/bash
# Rewrite git history so current branch appears to be spawned from a target branch
# Usage: ./rebase-branch-history.sh <target-branch>
# Example: ./rebase-branch-history.sh 21-azure-keyvault
# sudo chmod +x ./rebase-branch-history.sh

set -e

# Check if target branch is provided
if [ $# -eq 0 ]; then
    echo "Error: Target branch not specified"
    echo "Usage: $0 <target-branch>"
    echo "Example: $0 21-azure-keyvault"
    exit 1
fi

TARGET_BRANCH=$1
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Current branch: $CURRENT_BRANCH"
echo "Target branch: $TARGET_BRANCH"

# Check if target branch exists
if ! git show-ref --verify --quiet refs/heads/$TARGET_BRANCH; then
    echo "Error: Target branch '$TARGET_BRANCH' does not exist locally"
    echo "Available branches:"
    git branch
    echo "Aborting..."
    exit 1
fi

# Check if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: You have uncommitted changes. Please commit or stash them first."
    git status --short
    echo "Aborting..."
    exit 1
fi


# Backup current branch
BACKUP_BRANCH="${CURRENT_BRANCH}-backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup branch: $BACKUP_BRANCH"
git branch $BACKUP_BRANCH


# Get the commit hash of the target branch
TARGET_COMMIT=$(git rev-parse $TARGET_BRANCH)
echo "Target commit: $TARGET_COMMIT"


# Find the merge base (common ancestor) between current and target branches
MERGE_BASE=$(git merge-base $CURRENT_BRANCH $TARGET_BRANCH 2>/dev/null || echo "")

if [ -z "$MERGE_BASE" ]; then
    # For orphaned branches, we rebase the entire current branch history target
    echo "No common ancestor found between branches (orphaned histories)"
    echo "Graft $CURRENT_BRANCH history $TARGET_BRANCH by rebasing all commits"
    MERGE_BASE=""

else
    echo "Common ancestor found. $MERGE_BASE"
    echo "Aborting..."
    exit 0
fi

# Perform the rebase
echo "Rebasing $CURRENT_BRANCH history $TARGET_BRANCH..."
echo "Auto-resolving ALL conflicts by accepting current branch changes..."

# For orphaned branches, use recursive strategy with ours preference
GIT_MERGE_AUTOEDIT=no git -c core.editor=true rebase -s recursive -X ours $TARGET_BRANCH


if [ $? -eq 0 ]; then
    echo "Rebase completed successfully!"
    echo "Branch '$CURRENT_BRANCH' now appears to be spawned from '$TARGET_BRANCH'"
    echo ""
    echo "To push the rewritten history to remote (WARNING: This will force push):"
    echo "  git push --force-with-lease origin $CURRENT_BRANCH"
    echo ""
    echo "If something went wrong, you can restore from backup:"
    echo "  git reset --hard $BACKUP_BRANCH"
    echo "  git branch -D $BACKUP_BRANCH"
else
    echo "Rebase failed. You may need to resolve conflicts."
    echo "After resolving conflicts, run: git rebase --continue"
    echo "To abort the rebase: git rebase --abort"
    echo "To restore from backup: git reset --hard $BACKUP_BRANCH"
fi
