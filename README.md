<p align="center"> 
  <br/>
  <a href="https://opensource.org/license/agpl-v3"><img src="https://img.shields.io/badge/License-AGPL_v3-blue.svg?color=3F51B5&style=for-the-badge&label=License&logoColor=000000&labelColor=ececec" alt="License: AGPLv3"></a>
  <a href="https://discord.immich.app">
    <img src="https://img.shields.io/discord/979116623879368755.svg?label=Discord&logo=Discord&style=for-the-badge&logoColor=000000&labelColor=ececec" alt="Discord"/>
  </a>
  <br/>
  <br/>
</p>

<p align="center">
<img src="design/immich-logo-stacked-light.svg" width="300" title="Login With Custom URL">
</p>
<h3 align="center">High performance self-hosted photo and video management solution</h3>
<br/>
<br/>
 

<h4 align="left">Automatically deployed to my Ubuntu Server with Docker Compose via GitHub Actions whenever changes are pushed to main</h3>
<br/>
<br/>

> [!NOTE]
> You can find the main documentation, including installation guides, at https://immich.app/.

## Docker Deploy

1. Copy `.env.example` to `.env` and fill in production values.
2. Review environment variable meanings in the official docs: https://docs.immich.app/install/environment-variables.
3. Start or update the stack:

```bash
docker compose up -d
```

4. Pull latest images before updating (recommended):

```bash
docker compose pull
docker compose up -d
```

## GitHub Actions Deployment

Workflow: `.github/workflows/deploy-immich.yml`

Triggers:
- Push to `main`
- Manual run (`workflow_dispatch`)

Required GitHub secrets (repo-level or Environment `production`):
- `DEPLOY_USER`
- `DEPLOY_HOST`
- `DEPLOY_PATH`
- `DEPLOY_SSH_PRIVATE_KEY`

Optional GitHub secret:
- `DEPLOY_PORT` (defaults to `22`)

Server requirements for encrypted env deploys:
- `sops` must be installed on the server.
- The server must have an Age private key matching one of the public recipients listed in `.sops.yaml`.

## Encrypt `.env` to `.env.sops` (Manual)

Use SOPS locally whenever `.env` changes:

```bash
sops --encrypt --input-type dotenv --output-type dotenv .env > .env.sops
chmod 600 .env.sops
```

If you rotate or add Age keys, update recipients in `.sops.yaml` under `creation_rules[].age`, then re-encrypt:

```bash
sops updatekeys .env.sops
```

