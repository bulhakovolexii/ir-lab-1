#!/bin/bash
# Point the site at a broadcast server (or turn the broadcast off).
#   stream/set-server.sh 1.2.3.4   -> BROADCAST_SERVER = '1-2-3-4.sslip.io'
#   stream/set-server.sh off       -> BROADCAST_SERVER = '' (site makes no broadcast requests)
# Then commit and push index.html.
set -euo pipefail
cd "$(dirname "$0")/.."

arg="${1:-}"
if [[ "$arg" == "off" ]]; then
  host=""
elif [[ "$arg" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  host="${arg//./-}.sslip.io"
else
  echo "Usage: $0 <server-ipv4> | off" >&2
  exit 1
fi

grep -q "const BROADCAST_SERVER = '" index.html || { echo "BROADCAST_SERVER not found in index.html" >&2; exit 1; }
# sed -i differs between macOS and Linux; a temp file works on both.
sed "s|const BROADCAST_SERVER = '[^']*';|const BROADCAST_SERVER = '${host}';|" index.html > index.html.tmp
mv index.html.tmp index.html
grep -n "const BROADCAST_SERVER" index.html

if [[ -n "$host" ]]; then
  echo
  echo "Server check:  https://${host}   (should say \"Broadcast server\")"
  echo "OBS server:    https://${host}/live/whip"
  echo
  echo "git commit -am \"Broadcast server: ${arg}\" && git push"
else
  echo
  echo "git commit -am \"Broadcast off\" && git push"
fi
