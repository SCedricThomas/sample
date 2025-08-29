#!/usr/bin/env bash
# auto-pr-committer-ci-fast.sh
# Automates empty commits, waits for CI to pass without long sleeps, merges PRs to main.

set -euo pipefail

trap 'echo -e "\n🛑 Stopping auto-committer."; exit 0' SIGINT

counter=1

while true; do
  # Random delay to simulate coding between commits
  delay=$(( RANDOM % 31 + 10 ))  # 10–40s
  echo "⏳ Simulating coding for $delay seconds..."
  sleep "$delay"

  base_branch="main"
  feature_branch="auto-pr-$counter-$RANDOM"

  echo "🌱 Creating branch $feature_branch from $base_branch"
  git checkout -b "$feature_branch" "$base_branch"

  commit_msg="chore: simulated commit #$counter"
  echo "📝 Creating empty commit: $commit_msg"
  git commit --allow-empty -m "$commit_msg"

  echo "🚀 Pushing branch $feature_branch"
  git push origin "$feature_branch"

  echo "🔀 Creating PR..."
  pr_url=$(gh pr create --base "$base_branch" --head "$feature_branch" --title "$commit_msg" --body "Automated simulated PR #$counter")
  pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')

  # Get latest commit SHA of PR
  pr_sha=$(gh pr view "$pr_number" --json commits --jq '.commits[-1].oid')

  echo "⏳ Waiting for CI to pass on commit $pr_sha..."
  while true; do
    # Get raw check output
    raw_checks=$(gh pr checks "$pr_number" || true)

    # Check if any line contains "fail" or "cancelled"
    if echo "$raw_checks" | grep -qiE 'fail|cancelled'; then
      echo "❌ Some CI checks failed. Skipping merge."
      break
    fi

    # Check if all lines contain "pass"
    if echo "$raw_checks" | awk '{print $2}' | grep -qv 'pass'; then
      echo "🕒 CI still running..."
      sleep 5
    else
      echo "✅ All CI checks passed!"
      # Merge PR
      gh pr merge "$pr_number" --merge --delete-branch
      git checkout "$base_branch"
      git pull origin "$base_branch"
      break
    fi
  done

  counter=$((counter + 1))
done
