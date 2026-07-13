#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT_NAME="${1:-production}"
SECRET_NAME="${2:-IMMICH_ENV_FILE}"
ENV_FILE_PATH="${3:-.env}"

if [[ ! -f "$ENV_FILE_PATH" ]]; then
  echo "Missing env file: $ENV_FILE_PATH"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install gh, then run: gh auth login"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Run: gh auth login"
  exit 1
fi

REPO_SLUG="$(gh repo view --json nameWithOwner -q .nameWithOwner)"

if [[ -z "$REPO_SLUG" ]]; then
  echo "Could not determine repository from current directory"
  exit 1
fi

# Update Actions environment secret from local .env content.
gh secret set "$SECRET_NAME" --env "$ENVIRONMENT_NAME" --repo "$REPO_SLUG" < "$ENV_FILE_PATH"

echo "Updated $SECRET_NAME in environment $ENVIRONMENT_NAME for $REPO_SLUG"
