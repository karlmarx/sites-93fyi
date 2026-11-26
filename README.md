# sites-93fyi

One repo for small static sites on 93.fyi subdomains. Each folder in `sites/` becomes `<folder>.93.fyi`, served by its own assets-only Cloudflare Worker. The Worker's custom domain makes Cloudflare create the DNS record, so no DNS edits are needed.

## Add a site
1. `scripts/new-site.sh <name>` (creates `sites/<name>/` from `_template/`).
2. Put the static files in `sites/<name>/public/` (index.html at minimum).
3. Commit and push to `main`. The Action deploys only the sites that changed.

Redeploy one site by hand: Actions > "Deploy changed sites" > Run workflow, enter the folder name.

## One-time setup
Repo secret `CLOUDFLARE_API_TOKEN` (same token as lt-pickleball, needs Workers Scripts edit and Workers Routes / DNS edit on the 93.fyi zone).

## Sites
- `seaworld` -> seaworld.93.fyi: editable Thanksgiving park day plan (Nov 26, 2026).

## Making a site public (no login)

Your Cloudflare Zero Trust has an Access app ("93.fyi Subdomains") that puts a login in front of every *.93.fyi subdomain. To make one site public without touching that wildcard:

1. Cloudflare dashboard, Zero Trust, Access, Applications, Add an application, Self-hosted.
2. Application domain: `<name>.93.fyi` (exact hostname, not a wildcard).
3. Add a policy with Action **Bypass**, Include **Everyone**. Save.

A more specific hostname wins over the wildcard, so only that site becomes public. The deploy token cannot do this; it needs Access permissions.
