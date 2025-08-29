#!/usr/bin/env bash
# auto-empty-committer.sh
# Simulates coding by creating incremental empty commits via PRs into main.

set -euo pipefail

trap 'echo -e "\n🛑 Stopping auto-committer."; exit 0' SIGINT

counter=1

while true; do
  # Sleep 10-40 secs randomly
  delay=$(( (RANDOM % 30) + 10 ))
  echo "⏳ Waiting $delay seconds before next PR..."
  sleep "$delay"

  # Ensure we're on main and up-to-date
  git checkout main
  git pull origin main

  branch="auto-commit-$counter-$(date +%s)"
  msg="chore: simulated commit #$counter"

  echo "🌱 Creating branch: $branch"
  git checkout -b "$branch"

  echo "📝 Creating empty commit: $msg"
  git commit --allow-empty -m "$msg"

  echo "🚀 Pushing branch to origin..."
  git push -u origin "$branch"

  echo "🔀 Creating PR into main..."
  pr_url=$(gh pr create --base main --head "$branch" --title "$msg" --body "Automated simulated commit $counter")
  echo "📌 PR created: $pr_url"

  echo "✅ Merging PR..."
  gh pr merge --merge --delete-branch --auto "$pr_url"

  counter=$((counter + 1))
done
