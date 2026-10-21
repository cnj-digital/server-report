#!/usr/bin/env bash
# Usage: curl -fsSL https://raw.githubusercontent.com/cnj-digital/server-report/main/install.sh | sudo bash -s PINGKEY
set -e
[ -n "$1" ] || { echo "usage: curl ... | sudo bash -s PINGKEY"; exit 1; }
curl -fsSL https://raw.githubusercontent.com/cnj-digital/server-report/main/server-report -o /usr/local/bin/server-report
chmod 755 /usr/local/bin/server-report
echo "$1" > /etc/server-report.key
echo '*/15 * * * * root /usr/local/bin/server-report' > /etc/cron.d/server-report
/usr/local/bin/server-report && echo ok
