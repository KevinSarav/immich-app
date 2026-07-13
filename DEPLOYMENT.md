# GitHub Actions deploy for Immich (public repo safe)

This setup keeps secrets out of git and deploys to your server over SSH.
On each push to `main`, GitHub Actions tells your server to `git pull` (via fetch/reset) and then run Docker Compose.

## 1) Initialize git and push to GitHub

```bash
cd <local-path>/immich-app
git init
git add .
git commit -m "Add Immich GitHub Actions deploy workflow"
# create empty GitHub repo first, then:
git remote add origin git@github.com:<your-user>/<your-repo>.git
git branch -M main
git push -u origin main
```

## 2) Create GitHub Environment

In GitHub repo settings:
1. Go to `Settings -> Environments -> New environment`
2. Name it `production`
3. (Optional but recommended) add required reviewers so deployments need approval.

## 3) Add repository/environment secrets

Use either repo secrets or environment secrets (recommended: environment `production`):

- `DEPLOY_HOST`: server hostname/IP
- `DEPLOY_PORT`: usually `22`
- `DEPLOY_USER`: SSH user on server
- `DEPLOY_PATH`: deployment folder, example `/srv/immich-app`
- `DEPLOY_SSH_PRIVATE_KEY`: private key that can SSH to the server user
- `IMMICH_ENV_FILE`: full multiline content of your production `.env`

`IMMICH_ENV_FILE` should be the exact text of your `.env` file.

## 4) One-time server bootstrap

On the server, clone the repo into your target deploy path once:

```bash
mkdir -p /srv
cd /srv
git clone git@github.com:<your-user>/<your-repo>.git immich-app
cd immich-app
```

Add the production env file on server:

```bash
cp .env.example .env
# then edit .env with real values
```

## 5) Configure server side access

On your server, ensure the matching SSH public key is in:

```text
~/.ssh/authorized_keys
```

And ensure `DEPLOY_USER` can run Docker commands (often by membership in the `docker` group).
Also make sure the cloned repo in `DEPLOY_PATH` can pull from GitHub non-interactively (SSH deploy key or HTTPS token).

## 6) Deploy behavior

- Push to `main` triggers Actions, which SSHes to your server and runs:
	- `git fetch --prune origin`
	- `git checkout main`
	- `git reset --hard origin/main`
	- `docker compose pull && docker compose up -d --remove-orphans`
- Manual run (`workflow_dispatch`) has option `sync_env=true` to overwrite remote `.env` from `IMMICH_ENV_FILE` secret.

Recommended routine:
- Day-to-day: push to `main`; server auto-pulls and deploys
- Secret rotation or env updates: run manual workflow with `sync_env=true`

## 7) Security notes for public repo

- `.env` is gitignored and never committed.
- GitHub Secrets are not exposed in public repo source.
- Secrets are not provided to workflows triggered from untrusted fork PRs.
- Avoid printing secrets in workflow logs.

## 8) Optional hardening

- Use a dedicated deploy user with limited sudo rights.
- Restrict the SSH key in `authorized_keys` with source IP or command restrictions if possible.
- Keep host firewall open only for required ports.
