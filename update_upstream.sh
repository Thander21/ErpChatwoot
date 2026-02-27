#!/bin/bash

# Configuration
UPSTREAM_REPO="https://github.com/chatwoot/chatwoot.git"
BRANCH="develop" # 'latest' is not a branch in Chatwoot's git repo
TARGET_DIR="chatwoot-base"
TEMP_DIR="temp_upstream"

echo "🔄 Updating Chatwoot Base from Upstream ($BRANCH)..."

# 1. Clean previous temp
rm -rf $TEMP_DIR

# 2. Clone latest upstream
echo "📥 Cloning latest version..."
git clone --depth 1 --branch $BRANCH $UPSTREAM_REPO $TEMP_DIR

# 3. Create target if not exists
mkdir -p $TARGET_DIR

# 4. Sync files (excluding .git)
echo "📂 Syncing files..."
rsync -av --delete --exclude='.git' --exclude='.github' $TEMP_DIR/ $TARGET_DIR/

# 5. Cleanup
rm -rf $TEMP_DIR

echo "✅ Chatwoot Base updated successfully!"
echo "⚠️  Now you need to commit the changes:"
echo "   git add chatwoot-base"
echo "   git commit -m 'Update chatwoot-base to latest'"
