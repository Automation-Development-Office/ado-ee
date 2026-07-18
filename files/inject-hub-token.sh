#!/bin/sh
# Inject Automation Hub token from a BuildKit/Podman secret into ansible.cfg.
# Secret mount id: automation_hub_token -> /run/secrets/automation_hub_token
set -eu

CFG="${1:-/etc/ansible/ansible.cfg}"
SECRET_FILE="${2:-/run/secrets/automation_hub_token}"

if [ ! -f "${SECRET_FILE}" ]; then
  echo "ERROR: secret file not found at ${SECRET_FILE}" >&2
  echo "Pass --secret id=automation_hub_token,src=<token-file> (or CI secrets/secret-files)." >&2
  exit 1
fi

TOKEN="$(cat "${SECRET_FILE}")"
if [ -z "${TOKEN}" ]; then
  echo "ERROR: automation_hub_token secret is empty" >&2
  exit 1
fi

# Use Python so JWT characters cannot break sed.
python3 - "${CFG}" "${TOKEN}" <<'PY'
import sys
from pathlib import Path

cfg_path = Path(sys.argv[1])
token = sys.argv[2]
text = cfg_path.read_text()
placeholder = "__AUTOMATION_HUB_TOKEN__"
if placeholder not in text:
    raise SystemExit(f"ERROR: placeholder {placeholder} not found in {cfg_path}")
cfg_path.write_text(text.replace(placeholder, token))
print(f"Injected Automation Hub token into {cfg_path}")
PY
