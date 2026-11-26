#!/usr/bin/env bash
# Usage: scripts/new-site.sh <subdomain>   e.g. scripts/new-site.sh picnic  -> picnic.93.fyi
set -euo pipefail
name="${1:?subdomain required}"
[[ "$name" =~ ^[a-z0-9-]+$ ]] || { echo "use lowercase letters, digits, dashes"; exit 1; }
dest="sites/$name"
[[ -e "$dest" ]] && { echo "$dest already exists"; exit 1; }
cp -r _template "$dest"
sed -i "s/__NAME__/$name/g" "$dest/wrangler.jsonc" "$dest/public/index.html"
echo "Created $dest. Put the site in $dest/public, commit, push to main."
