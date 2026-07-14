#!/usr/bin/env bash
set -euo pipefail

DEPLOY_PATH="${DEPLOY_PATH:-$HOME/apps/immich-app}"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-main}"

cd "$DEPLOY_PATH"

if [[ ! -d .git ]]; then
  echo "Missing git repository in $DEPLOY_PATH"
  echo "Clone your GitHub repo at this path first"
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Git remote origin is not configured in $DEPLOY_PATH"
  exit 1
fi

# Make working tree match the latest commit on the deployment branch.
git fetch --prune origin
git checkout "$DEPLOY_BRANCH"
git reset --hard "origin/$DEPLOY_BRANCH"

if [[ -f .env.sops ]]; then
  if ! command -v sops >/dev/null 2>&1; then
    echo "Found $DEPLOY_PATH/.env.sops but sops is not installed on server"
    exit 1
  fi

  tmp_env="$(mktemp)"
  trap 'rm -f "$tmp_env"' EXIT

  echo "Decrypting $DEPLOY_PATH/.env.sops to runtime .env"
  sops --decrypt --input-type dotenv --output-type dotenv .env.sops > "$tmp_env"
  install -m 600 "$tmp_env" .env
  rm -f "$tmp_env"
  trap - EXIT
fi

if [[ ! -f .env ]]; then
  echo "Missing $DEPLOY_PATH/.env on server"
  echo "Commit .env.sops (encrypted) or create .env manually on server"
  exit 1
fi

# Pull latest images and recreate containers in place.
docker compose --env-file .env pull

docker compose --env-file .env up -d --remove-orphans

docker image prune -f >/dev/null 2>&1 || true

echo "Immich deployment completed from branch $DEPLOY_BRANCH in $DEPLOY_PATH"
