#!/usr/bin/env bash
# Clave fija demo-access en host-setup/keys/
# Uso: bash host-setup/scripts/deploy/ensure-demo-access-key.sh
#
# Importar clave existente (opcional, ruta explícita del evaluador):
#   DEMO_SSH_KEY_FILE=/ruta/al/demo-access bash host-setup/scripts/deploy/ensure-demo-access-key.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST_SETUP="$(cd "${SCRIPT_DIR}/../.." && pwd)"
KEYS_DIR="${HOST_SETUP}/keys"
PRV="${KEYS_DIR}/demo-access"
PUB="${PRV}.pub"

mkdir -p "${KEYS_DIR}"

if [[ -f "${PUB}" ]]; then
  exit 0
fi

if [[ -n "${DEMO_SSH_KEY_FILE:-}" && -f "${DEMO_SSH_KEY_FILE}.pub" ]]; then
  cp -a "${DEMO_SSH_KEY_FILE}" "${PRV}"
  cp -a "${DEMO_SSH_KEY_FILE}.pub" "${PUB}"
  chmod 600 "${PRV}"
  exit 0
fi

echo "Generando clave fija demo-access (primera vez)..." >&2
ssh-keygen -t ed25519 -f "${PRV}" -N "" -C "demo-access@lab" >/dev/null
chmod 600 "${PRV}"
