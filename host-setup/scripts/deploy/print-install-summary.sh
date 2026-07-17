#!/usr/bin/env bash
# Resumen post-install: evaluador, participante en el host, entrega.
# Uso: bash host-setup/scripts/deploy/print-install-summary.sh demo1.conatel-lab.conatel.cloud
set -euo pipefail

HOST="${1:?Falta hostname — ej: demo1.conatel-lab.conatel.cloud}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST_SETUP="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPO_ROOT="$(cd "${HOST_SETUP}/.." && pwd)"
PRV="${HOST_SETUP}/keys/demo-access"

bash "${SCRIPT_DIR}/ensure-demo-access-key.sh" 2>/dev/null
chmod 600 "${PRV}" 2>/dev/null || true

KEY_DISPLAY="${PRV}"
[[ "${PRV}" == "${REPO_ROOT}/"* ]] && KEY_DISPLAY="${PRV#${REPO_ROOT}/}"

cat <<EOF

══════════════════════════════════════════════════════════════
  EVALUADOR
══════════════════════════════════════════════════════════════

Comandos disponibles para el evaluador:

  - Verificar estado inicial
    - lab-check
  - Restablecer estado inicial
    - lab-reset
  - Disparar incidente (Parte 3)
    - disparar-incidente
  - Restaurar incidente (Parte 3)
    - restaurar-incidente

Rutas en ${HOST}:

  /opt/prueba-tecnica-eval/
  ├── incident.conf            # falla simulada (Parte 3, editable)
  ├── cisco-credentials.env    # credenciales Ansible Cisco (editable)
  ├── bin/                     # lab-check, lab-reset, disparar-incidente, restaurar-incidente
  ├── ansible/                 # playbooks incidente / rollback
  └── state/                   # lock incidente, ansible.log

══════════════════════════════════════════════════════════════
  PARTICIPANTE (servidor)
══════════════════════════════════════════════════════════════

Conexión:

  ssh -i ~/.ssh/demo-access demo@${HOST}

Comandos disponibles para el participante:

  - Diagnóstico Cisco (solo lectura)
    - ssh-rtr
    - ssh-core
    - ssh-edge

  - Remediación Ansible
    - lab-ansible <playbook.yml>
  
  - Ejecutar incidente (Parte 3)
    - disparar-incidente

Rutas en ${HOST}:

  ~/prueba-tecnica/
  ├── README.md                # mapa del directorio de trabajo
  ├── app/                     # solución web (Docker)
  ├── ansible/                 # inventario + playbooks (Parte 3)
  │   ├── ansible.cfg
  │   ├── inventory/
  │   │   ├── group_vars/
  │   │   ├── host_vars/
  │   │   └── hosts.yml
  │   └── playbooks/
  │       └── participante/    # playbooks del participante (.yml) (Parte 3)
  ├── scripts/                 # lab-ansible, aliases — no modificar
  └── .env.prueba-tecnica      # variables ZABBIX_*

══════════════════════════════════════════════════════════════
  ENTREGA AL PARTICIPANTE
══════════════════════════════════════════════════════════════

  docs/consigna-participante.md
  docs/plantilla-entrega.md  (pasos detallados en sección «Cómo conectarte»)
  ${KEY_DISPLAY}

══════════════════════════════════════════════════════════════
EOF
