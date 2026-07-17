#!/usr/bin/env bash
# Instala automatismos de prueba técnica en la VM demo (demo1, demo2, …).
# Evaluador: SSH como ubuntu. Participante: SSH como demo (sin sudo libre).
# Uso: bash host-setup/install-on-demo-vm.sh demoX.dominio
set -euo pipefail

HOST="${1:?Falta hostname — ej: demoX.dominio}"
SRC="$(cd "$(dirname "$0")" && pwd)"
REMOTE_ADMIN="${2:-ubuntu@${HOST}}"
DEMO_USER="demo"
DEMO_HOME="/home/${DEMO_USER}"
STAGING="/tmp/prueba-tecnica-staging-$$"
KEYS_DIR="${SRC}/keys"
DEMO_ACCESS_PUB="${KEYS_DIR}/demo-access.pub"
PARTICIPANT_SCRIPTS="${SRC}/scripts/participant"
DEPLOY_SCRIPTS="${SRC}/scripts/deploy"

SSH=(ssh -o LogLevel=ERROR -o StrictHostKeyChecking=accept-new)
SCP=(scp -q -o LogLevel=ERROR -o StrictHostKeyChecking=accept-new)
RSYNC=(rsync -az --info=stats2 -e "ssh -o LogLevel=ERROR -o StrictHostKeyChecking=accept-new")

step() { printf '  %-18s ' "$1"; }
ok()   { echo "OK"; }
warn() { echo "AVISO — $*"; }
fail() { echo "FAIL"; echo "Error: $*" >&2; exit 1; }

bash "${DEPLOY_SCRIPTS}/ensure-demo-access-key.sh" 2>/dev/null

if [[ ! -f "${DEMO_ACCESS_PUB}" ]]; then
  fail "falta ${DEMO_ACCESS_PUB}"
fi

echo "==> ${HOST}"
echo ""

step "Usuario demo"
"${SSH[@]}" "$REMOTE_ADMIN" "id ${DEMO_USER} >/dev/null" || \
  fail "usuario ${DEMO_USER} no existe — actualizá el despliegue demo (up/update)"
ok

step "Participante"
"${SSH[@]}" "$REMOTE_ADMIN" "rm -rf ${STAGING} && mkdir -p ${STAGING}/ansible/playbooks/participante ${STAGING}/scripts ${STAGING}/app"
if command -v rsync >/dev/null 2>&1 && "${SSH[@]}" "$REMOTE_ADMIN" 'command -v rsync >/dev/null 2>&1'; then
  "${RSYNC[@]}" "${SRC}/ansible/" "${REMOTE_ADMIN}:${STAGING}/ansible/" >/dev/null
  "${RSYNC[@]}" "${PARTICIPANT_SCRIPTS}/" "${REMOTE_ADMIN}:${STAGING}/scripts/" >/dev/null
  "${RSYNC[@]}" "${SRC}/app/" "${REMOTE_ADMIN}:${STAGING}/app/" >/dev/null
else
  "${SSH[@]}" "$REMOTE_ADMIN" "rm -rf ${STAGING} && mkdir -p ${STAGING}/ansible/playbooks/participante ${STAGING}/scripts ${STAGING}/app"
  tar -C "${SRC}" -czf - ansible | "${SSH[@]}" "$REMOTE_ADMIN" "tar -xzf - -C ${STAGING}"
  tar -C "${PARTICIPANT_SCRIPTS}" -czf - . | "${SSH[@]}" "$REMOTE_ADMIN" "tar -xzf - -C ${STAGING}/scripts"
  tar -C "${SRC}/app" -czf - . | "${SSH[@]}" "$REMOTE_ADMIN" "tar -xzf - -C ${STAGING}/app"
fi
"${SCP[@]}" "${SRC}/ssh/config.d/prueba-tecnica" "${REMOTE_ADMIN}:${STAGING}/prueba-tecnica-ssh-config"
"${SCP[@]}" "${SRC}/workdir/README.md" "${REMOTE_ADMIN}:${STAGING}/prueba-tecnica-README.md"
"${SCP[@]}" "${SRC}/python/sitecustomize.py" "${REMOTE_ADMIN}:/tmp/sitecustomize-prueba-tecnica.py"
"${SCP[@]}" "${DEPLOY_SCRIPTS}/lab-check" "${DEPLOY_SCRIPTS}/lab-reset" "${REMOTE_ADMIN}:/tmp/"
ok

step "Zabbix (.env)"
if [[ -f "${SRC}/env.prueba-tecnica" ]]; then
  "${SCP[@]}" "${SRC}/env.prueba-tecnica" "${REMOTE_ADMIN}:/tmp/env.prueba-tecnica"
  ok
else
  warn "falta host-setup/env.prueba-tecnica (ver env.example)"
fi

step "Evaluador (/opt)"
tar -C "${SRC}/evaluator" -czf - --exclude='cisco-credentials.env' . | \
  "${SSH[@]}" "$REMOTE_ADMIN" 'sudo mkdir -p /opt/prueba-tecnica-eval && sudo tar -xzf - -C /opt/prueba-tecnica-eval && sudo chown -R root:root /opt/prueba-tecnica-eval'
if [[ -f "${SRC}/evaluator/cisco-credentials.env" ]]; then
  "${SCP[@]}" "${SRC}/evaluator/cisco-credentials.env" "${REMOTE_ADMIN}:/tmp/cisco-credentials.env"
  "${SSH[@]}" "$REMOTE_ADMIN" 'sudo install -o root -g root -m 600 /tmp/cisco-credentials.env /opt/prueba-tecnica-eval/cisco-credentials.env && rm -f /tmp/cisco-credentials.env'
else
  warn "falta evaluator/cisco-credentials.env"
fi
ok

step "Clave demo-access"
"${SCP[@]}" "${DEMO_ACCESS_PUB}" "${REMOTE_ADMIN}:/tmp/demo-access.pub"
"${SSH[@]}" "$REMOTE_ADMIN" "sudo install -d -o ${DEMO_USER} -g ${DEMO_USER} -m 700 ${DEMO_HOME}/.ssh && sudo install -o ${DEMO_USER} -g ${DEMO_USER} -m 600 /tmp/demo-access.pub ${DEMO_HOME}/.ssh/authorized_keys && rm -f /tmp/demo-access.pub"
ok

step "Configuración VM"
"${SSH[@]}" "$REMOTE_ADMIN" env DEMO_USER="${DEMO_USER}" DEMO_HOME="${DEMO_HOME}" STAGING="${STAGING}" bash -s >/dev/null <<'REMOTE'
set -euo pipefail

sudo mkdir -p "${DEMO_HOME}/prueba-tecnica/ansible" "${DEMO_HOME}/prueba-tecnica/scripts" "${DEMO_HOME}/prueba-tecnica/app" "${DEMO_HOME}/.ssh/config.d"
sudo find "${DEMO_HOME}/prueba-tecnica" -mindepth 1 -maxdepth 1 ! -name ansible ! -name scripts ! -name app -exec rm -rf {} +
if command -v rsync >/dev/null 2>&1; then
  sudo rsync -a --delete "${STAGING}/ansible/" "${DEMO_HOME}/prueba-tecnica/ansible/"
  sudo rsync -a --delete "${STAGING}/scripts/" "${DEMO_HOME}/prueba-tecnica/scripts/"
  sudo rsync -a --delete "${STAGING}/app/" "${DEMO_HOME}/prueba-tecnica/app/"
else
  sudo rm -rf "${DEMO_HOME}/prueba-tecnica/ansible" "${DEMO_HOME}/prueba-tecnica/scripts" "${DEMO_HOME}/prueba-tecnica/app"
  sudo mkdir -p "${DEMO_HOME}/prueba-tecnica/ansible" "${DEMO_HOME}/prueba-tecnica/scripts" "${DEMO_HOME}/prueba-tecnica/app"
  sudo cp -a "${STAGING}/ansible/." "${DEMO_HOME}/prueba-tecnica/ansible/"
  sudo cp -a "${STAGING}/scripts/." "${DEMO_HOME}/prueba-tecnica/scripts/"
  sudo cp -a "${STAGING}/app/." "${DEMO_HOME}/prueba-tecnica/app/"
fi
sudo find "${DEMO_HOME}/prueba-tecnica/scripts" -mindepth 1 -maxdepth 1 \
  ! -name 'lab-ansible' ! -name 'aliases.sh' -exec rm -f {} +
sudo install -o "${DEMO_USER}" -g "${DEMO_USER}" -m 600 "${STAGING}/prueba-tecnica-ssh-config" "${DEMO_HOME}/.ssh/config.d/prueba-tecnica"
sudo install -o "${DEMO_USER}" -g "${DEMO_USER}" -m 644 "${STAGING}/prueba-tecnica-README.md" "${DEMO_HOME}/prueba-tecnica/README.md"
sudo rm -rf "${STAGING}"

if [[ -f /tmp/env.prueba-tecnica ]]; then
  sudo install -o "${DEMO_USER}" -g "${DEMO_USER}" -m 600 /tmp/env.prueba-tecnica "${DEMO_HOME}/prueba-tecnica/.env.prueba-tecnica"
  rm -f /tmp/env.prueba-tecnica
fi
sudo rm -f "${DEMO_HOME}/.env.prueba-tecnica"

sudo chown -R "${DEMO_USER}:${DEMO_USER}" "${DEMO_HOME}/prueba-tecnica" "${DEMO_HOME}/.ssh"

sudo -u "${DEMO_USER}" bash -s <<'DEMO'
set -euo pipefail

chmod +x ~/prueba-tecnica/scripts/lab-ansible 2>/dev/null || true

PATH_LINE='export PATH="$HOME/prueba-tecnica/scripts:$PATH"'
for rc in .bashrc .zshrc .zprofile; do
  grep -q 'prueba-tecnica/scripts' "${HOME}/${rc}" 2>/dev/null || echo "${PATH_LINE}" >> "${HOME}/${rc}"
done

ENV_FILE="${HOME}/prueba-tecnica/.env.prueba-tecnica"
if [[ -f ~/.env.prueba-tecnica && ! -f "${ENV_FILE}" ]]; then
  mv ~/.env.prueba-tecnica "${ENV_FILE}"
fi
rm -f ~/.env.prueba-tecnica 2>/dev/null || true
sed -i '/^export ANSIBLE_CISCO_/d' "${ENV_FILE}" 2>/dev/null || true

grep -q 'prueba-tecnica' ~/.ssh/config 2>/dev/null || cat >> ~/.ssh/config <<'EOF'

# Prueba técnica — equipos Cisco
Include config.d/prueba-tecnica
EOF
chmod 600 ~/.ssh/config.d/prueba-tecnica 2>/dev/null || true

grep -q 'aliases.sh' ~/.bashrc 2>/dev/null || echo 'source ~/prueba-tecnica/scripts/aliases.sh 2>/dev/null' >> ~/.bashrc
grep -q 'aliases.sh' ~/.zshrc 2>/dev/null || echo 'source ~/prueba-tecnica/scripts/aliases.sh 2>/dev/null' >> ~/.zshrc

mkdir -p ~/prueba-tecnica/ansible/playbooks/participante

if [[ -f "${ENV_FILE}" ]]; then
  chmod 600 "${ENV_FILE}"
fi
sed -i '/env\.prueba-tecnica/d' ~/.bashrc 2>/dev/null || true
grep -q 'prueba-tecnica/.env.prueba-tecnica' ~/.bashrc 2>/dev/null || \
  echo '[ -f ~/prueba-tecnica/.env.prueba-tecnica ] && source ~/prueba-tecnica/.env.prueba-tecnica' >> ~/.bashrc

: > ~/.bash_history
: > ~/.zsh_history 2>/dev/null || true
history -c 2>/dev/null || true
DEMO

PYVER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
SYS_SITE="/usr/local/lib/python${PYVER}/dist-packages"
sudo mkdir -p "${SYS_SITE}"
sudo install -o root -g root -m 644 /tmp/sitecustomize-prueba-tecnica.py "${SYS_SITE}/sitecustomize.py"
rm -f /tmp/sitecustomize-prueba-tecnica.py

sudo install -o root -g ubuntu -m 750 /tmp/lab-check /opt/prueba-tecnica-eval/bin/lab-check
sudo install -o root -g ubuntu -m 750 /tmp/lab-reset /opt/prueba-tecnica-eval/bin/lab-reset
rm -f /tmp/lab-check /tmp/lab-reset
sudo rm -f /usr/local/bin/lab-check /usr/local/bin/lab-reset /usr/local/bin/restaurar-incidente

sudo chown -R root:root /opt/prueba-tecnica-eval
sudo chgrp ubuntu /opt/prueba-tecnica-eval
sudo chmod 750 /opt/prueba-tecnica-eval
sudo chown root:ubuntu /opt/prueba-tecnica-eval/bin
sudo chmod 750 /opt/prueba-tecnica-eval/bin
sudo chmod 700 /opt/prueba-tecnica-eval/bin/disparar-incidente /opt/prueba-tecnica-eval/bin/ansible-participante /opt/prueba-tecnica-eval/bin/restaurar-incidente-run
sudo chown root:ubuntu /opt/prueba-tecnica-eval/bin/lab-check /opt/prueba-tecnica-eval/bin/lab-reset /opt/prueba-tecnica-eval/bin/restaurar-incidente
sudo chmod 750 /opt/prueba-tecnica-eval/bin/lab-check /opt/prueba-tecnica-eval/bin/lab-reset /opt/prueba-tecnica-eval/bin/restaurar-incidente
sudo chown root:ubuntu /opt/prueba-tecnica-eval/incident.conf
sudo chmod 640 /opt/prueba-tecnica-eval/incident.conf
sudo chown root:ubuntu /opt/prueba-tecnica-eval/cisco-credentials.env
sudo chmod 640 /opt/prueba-tecnica-eval/cisco-credentials.env
sudo chown -R root:ubuntu /opt/prueba-tecnica-eval/ansible
sudo chmod -R 750 /opt/prueba-tecnica-eval/ansible
sudo mkdir -p /opt/prueba-tecnica-eval/state
sudo chown root:ubuntu /opt/prueba-tecnica-eval/state
sudo chmod 2770 /opt/prueba-tecnica-eval/state
sudo chmod 700 /opt/prueba-tecnica-eval/sudoers
sudo install -o root -g root -m 755 /opt/prueba-tecnica-eval/bin/disparar-incidente-wrapper /usr/local/bin/disparar-incidente
sudo rm -f /opt/prueba-tecnica-eval/state/incident.triggered 2>/dev/null || true

# Limpieza Docker (solución del participante anterior)
if command -v docker >/dev/null 2>&1; then
  sudo docker ps -aq 2>/dev/null | xargs -r sudo docker rm -f >/dev/null 2>&1 || true
  sudo docker system prune -af --volumes >/dev/null 2>&1 || true
fi

sudo tee /etc/profile.d/prueba-tecnica-evaluator.sh >/dev/null <<'PROFILE'
# Comandos evaluador prueba técnica (solo usuario ubuntu)
if [ "$(id -un)" = ubuntu ]; then
  export PATH="/opt/prueba-tecnica-eval/bin:${PATH}"
fi
PROFILE
sudo chmod 644 /etc/profile.d/prueba-tecnica-evaluator.sh

if [[ -d /home/ubuntu ]]; then
  UBUNTU_PATH='export PATH="/opt/prueba-tecnica-eval/bin:$PATH"'
  for rc in /home/ubuntu/.bashrc /home/ubuntu/.zshrc /home/ubuntu/.zprofile; do
    touch "${rc}" 2>/dev/null || sudo touch "${rc}"
    sudo chown ubuntu:ubuntu "${rc}"
    grep -q 'prueba-tecnica-eval/bin' "${rc}" 2>/dev/null || echo "${UBUNTU_PATH}" | sudo tee -a "${rc}" >/dev/null
  done
fi

sudo rm -f /etc/sudoers.d/prueba-tecnica-participante 2>/dev/null || true
sudo cp /opt/prueba-tecnica-eval/sudoers/prueba-tecnica-demo /etc/sudoers.d/prueba-tecnica-demo
sudo cp /opt/prueba-tecnica-eval/sudoers/prueba-tecnica-evaluator /etc/sudoers.d/prueba-tecnica-evaluator
sudo chmod 440 /etc/sudoers.d/prueba-tecnica-demo /etc/sudoers.d/prueba-tecnica-evaluator
sudo visudo -cf /etc/sudoers.d/prueba-tecnica-demo >/dev/null
sudo visudo -cf /etc/sudoers.d/prueba-tecnica-evaluator >/dev/null
REMOTE
ok

step "Paramiko (Ansible)"
if "${SSH[@]}" "$REMOTE_ADMIN" 'python3 -c "import paramiko"' 2>/dev/null; then
  ok
else
  "${SSH[@]}" "$REMOTE_ADMIN" 'sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-paramiko'
  ok
fi

step "Ansible (cisco)"
"${SSH[@]}" "$REMOTE_ADMIN" 'sudo rm -rf /home/demo/.ansible/pc 2>/dev/null || true'
ansible_out="$("${SSH[@]}" "$REMOTE_ADMIN" 'sudo -n /opt/prueba-tecnica-eval/bin/ansible-participante -- cisco -m cisco.ios.ios_command -a "commands=\"show ip interface brief\"" --one-line' 2>&1)" || true
ansible_ok=$(grep -c '| SUCCESS =>' <<<"${ansible_out}" || true)
ansible_fail=$(grep -cE '\| (FAILED|UNREACHABLE!) =>' <<<"${ansible_out}" || true)
if [[ "${ansible_ok}" -eq 3 && "${ansible_fail}" -eq 0 ]]; then
  echo "OK (3/3)"
else
  echo "parcial (${ansible_ok}/3 OK)"
  grep -E '^\S+ \| (SUCCESS|FAILED|UNREACHABLE!) =>' <<<"${ansible_out}" \
    | sed 's/ => .*//' | sed 's/^/    /' || true
fi

bash "${DEPLOY_SCRIPTS}/print-install-summary.sh" "${HOST}"
