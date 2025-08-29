#!/usr/bin/env bash
# auto-empty-committer.sh
# Simulates coding by creating incremental empty commits on main.

set -euo pipefail

trap 'echo -e "\n🛑 Stopping auto-committer."; exit 0' SIGINT

counter=1

while true; do
  # Sleep 1-30 secs randomly
  delay=$(( RANDOM % 30 ))  # < 30 seconds
  echo "⏳ Waiting $delay seconds before next commit..."
  sleep "$delay"

  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$branch" != "main" ]; then
    echo "⚠️ Not on main (currently: $branch). Skipping."
    continue
  fi

  msg="chore: simulated commit #$counter"
  echo "📝 Creating empty commit: $msg"
  git commit --allow-empty -m "$msg"

  echo "🚀 Pushing to origin/main..."
  git push origin main

  counter=$((counter + 1))
done
