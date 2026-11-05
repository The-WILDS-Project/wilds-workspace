#!/usr/bin/env bash
# Install the WILDS boot services (Linux, systemd). Run as root, after setup.sh has built
# the tree and the tree has been placed at /opt/wilds (owned by the wilds user).
#
# Copies root/ over / (never overwriting an existing /etc/wilds/wilds.env), creates the
# wilds user, and enables wilds.target so the services start at boot. Safe to re-run.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "run as root" >&2; exit 1; }
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

systemd-sysusers "$here/root/usr/lib/sysusers.d/wilds.conf"

for f in etc/systemd/system/wilds.target etc/systemd/system/wilds-control.service \
         etc/systemd/system/wilds-gui.service; do
  install -D -m 0644 "$here/root/$f" "/$f"
done

if [[ -e /etc/wilds/wilds.env ]]; then
  echo "kept     /etc/wilds/wilds.env"
else
  install -D -m 0640 -o root -g wilds "$here/root/etc/wilds/wilds.env" /etc/wilds/wilds.env
  echo "created  /etc/wilds/wilds.env  (set WILDS_GUI_SECRET_KEY!)"
fi

systemctl daemon-reload
systemctl enable wilds.target
echo "Enabled. Start now with: systemctl start wilds.target"
