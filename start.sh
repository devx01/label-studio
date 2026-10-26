#!/usr/bin/env bash
# The real Label Studio server behind the gateway: ./start.sh   (http://127.0.0.1:8088)
#
# First run: creates .venv (label-studio 1.23.2, Python 3.10+) and .env with the admin user's password and API token.
# The gateway reads LS_ADMIN_TOKEN from .env and is the only API client; the UI at :8088 is for admins on this machine.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${LS_PORT:-8088}"
HOST="${LS_HOST:-127.0.0.1}"  # Label Studio's own default is 0.0.0.0: every network
PY="${PYTHON:-python3.13}"

if [ ! -x .venv/bin/label-studio ]; then
  "$PY" -m venv .venv
  .venv/bin/pip install -q label-studio==1.23.2
fi

if [ ! -f .env ]; then  # generated once; never commit it
  umask 077
  {
    echo "LS_ADMIN_EMAIL=admin@example.com"
    echo "LS_ADMIN_PASSWORD=$(.venv/bin/python -c 'import secrets; print(secrets.token_urlsafe(18))')"
    echo "LS_ADMIN_TOKEN=$(.venv/bin/python -c 'import secrets; print(secrets.token_hex(20))')"
  } > .env
fi
set -a; . ./.env; set +a

export LABEL_STUDIO_BASE_DATA_DIR="$PWD/data"
mkdir -p data
# the admin user and its token are created on the first start and kept in data/ afterwards
exec .venv/bin/label-studio start --no-browser --internal-host "$HOST" --port "$PORT" --data-dir "$PWD/data" \
  --username "$LS_ADMIN_EMAIL" --password "$LS_ADMIN_PASSWORD" --user-token "$LS_ADMIN_TOKEN" \
  --enable-legacy-api-token
