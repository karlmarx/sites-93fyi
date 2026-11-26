# sites-93fyi

One repo for small static sites on 93.fyi subdomains. Each folder in `sites/` becomes `<folder>.93.fyi`, served by its own assets-only Cloudflare Worker. The Worker's custom domain makes Cloudflare create the DNS record, so no DNS edits are needed.

## Add a site
1. `scripts/new-site.sh <name>` (creates `sites/<name>/` from `_template/`).
2. Put the static files in `sites/<name>/public/` (index.html at minimum).
3. Commit and push to `main`. The Action deploys only the sites that changed.

Redeploy one site by hand: Actions > "Deploy changed sites" > Run workflow, enter the folder name.

## One-time setup
Repo secret `CLOUDFLARE_API_TOKEN`: a scoped API token (not the Global API Key) from the Edit Cloudflare Workers template with the 93.fyi zone, plus Account > Access: Apps and Policies > Edit.

## Sites
- `seaworld` -> seaworld.93.fyi: editable Thanksgiving park day plan (Nov 26, 2026).

## Sites are public by default
Your Cloudflare Zero Trust has a wildcard Access app ("93.fyi Subdomains") that puts a login in front of every *.93.fyi subdomain. After each deploy, `scripts/ensure-public.sh` creates a separate Access app for the site's exact hostname with a **Bypass / Everyone** policy, so that site opens with no login. The more specific hostname wins over the wildcard, and the wildcard app and other hostnames are never touched. If the hostname already has its own Access app, it is left alone.

To keep a site behind the login, add an empty `sites/<name>/.private` file before its first deploy.

The token needs one extra permission for this: Account > **Access: Apps and Policies** > **Edit**.
