#!/bin/bash

# Deploy Script for ErpChatwoot (Wrapper Strategy)
# Usage: ./deploy.sh [message]

MESSAGE="${1:-Update deployment}"

echo "🚀 Starting deployment..."

# 1. Update Upstream (chatwoot-base)
echo "📥 Updating chatwoot-base (upstream)..."
cd chatwoot-base
git pull origin main || echo "⚠️ Warning: Failed to pull chatwoot-base (might be detached or local changes)"
cd ..

# 2. Add Wrapper Changes
echo "📦 Staging changes in ErpChatwoot..."
git add .

# 3. Commit
echo "💾 Committing: $MESSAGE"
git commit -m "$MESSAGE"

# 4. Push (Triggers Coolify if configured)
echo "⬆️ Pushing to repository..."
git push origin main

echo "✅ Ready! Coolify should detect the new commit and rebuild using the root Dockerfile."
