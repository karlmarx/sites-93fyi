#!/usr/bin/env bash
# Make a deployed site public: ensure a Cloudflare Access self-hosted app exists
# for each of the site's exact hostnames with a Bypass / Everyone policy.
# Idempotent: an app already covering the exact hostname is left alone.
# Never touches wildcard apps (e.g. "93.fyi Subdomains") or other hostnames.
# Skip a site by putting an empty file named .private in its folder.
# Usage: scripts/ensure-public.sh sites/<name>   (needs CLOUDFLARE_API_TOKEN)
set -euo pipefail
dir="${1:?site folder}"
if [ -f "$dir/.private" ]; then echo "$dir is marked private, leaving Access alone"; exit 0; fi
: "${CLOUDFLARE_API_TOKEN:?missing}"
cfg=$(sed -e 's#^[[:space:]]*//.*$##' -e 's#[[:space:]]//[^"]*$##' "$dir/wrangler.jsonc")
acc=$(jq -r '.account_id' <<<"$cfg")
api="https://api.cloudflare.com/client/v4/accounts/$acc/access/apps"
auth=(-H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H "Content-Type: application/json")

apps=$(curl -fsS "${auth[@]}" "$api?per_page=1000") || {
  echo "::error::Could not list Access apps. The token needs Account > Access: Apps and Policies > Edit."; exit 1; }

for host in $(jq -r '.routes[]?.pattern' <<<"$cfg"); do
  if jq -e --arg h "$host" '.result[] | select(.domain == $h or ((.self_hosted_domains // []) | index($h)) or ((.destinations // []) | map(.uri) | index($h)))' <<<"$apps" >/dev/null; then
    echo "$host already has its own Access app, leaving it alone"
    continue
  fi
  body=$(jq -n --arg h "$host" '{
    name: ($h + " (public)"), type: "self_hosted", domain: $h,
    destinations: [{type: "public", uri: $h}],
    policies: [{name: "Public", decision: "bypass", include: [{everyone: {}}]}]
  }')
  curl -fsS "${auth[@]}" -X POST "$api" --data "$body" | jq -e '.success' >/dev/null
  echo "Created public (Bypass / Everyone) Access app for $host"
done
