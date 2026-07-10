# Host setup — servidor Linux de la prueba técnica

Automatismos del participante y del evaluador en la VM demo (Ansible, SSH, variables Zabbix, incidente Parte 3).

## Usuarios en la VM

| Usuario | Quién | Uso |
| --- | --- | --- |
| **`demo`** | Participante | SSH, app, playbooks, `disparar-incidente`, `lab-ansible`. Sin sudo libre. |
| **`ubuntu`** | Evaluador | Deploy, `lab-check`, `lab-reset`, `restaurar-incidente`. No entregar al participante. |

El usuario **`demo`** en Linux es distinto del usuario **`demo`** en equipos Cisco (SSH lectura) y del usuario **`demo`** en la API de Zabbix: mismo nombre, sistemas diferentes.

## Desplegar / actualizar

Desde tu máquina, con SSH a la VM como **`ubuntu`**:

```bash
bash host-setup/install-on-demo-vm.sh demoN.dominio
```

Requisito: la VM debe tener el usuario Linux **`demo`** (despliegue del servicio demo con up/update).
El install instala **`python3-paramiko`** si falta (Ansible `network_cli` hacia Cisco; el SSH manual no lo reemplaza).

### Clave SSH del participante

Par fijo en `host-setup/keys/demo-access` (+ `.pub`). El install sube la pública a `demo@`.

```bash
bash host-setup/install-on-demo-vm.sh demo1.conatel-lab.conatel.cloud
bash host-setup/scripts/deploy/print-install-summary.sh demo1.conatel-lab.conatel.cloud
```

Ver [`keys/README.md`](keys/README.md).

### Variables Zabbix (`~/prueba-tecnica/.env.prueba-tecnica` del usuario demo)

1. Copiar [`env.example`](env.example) → [`env.prueba-tecnica`](env.prueba-tecnica) (gitignored).
2. Completar `ZABBIX_URL`, `ZABBIX_USER`, `ZABBIX_PASSWORD`, `ZABBIX_TOKEN`.
3. Al correr el install, si existe `env.prueba-tecnica`, se sube a `/home/demo/prueba-tecnica/.env.prueba-tecnica`.

El participante lee esas variables en el servidor; no van en la plantilla de entrega. 
Referencia evaluador: [`docs/plantilla-evaluador.md`](../docs/plantilla-evaluador.md).

### Credenciales Ansible Cisco (`/opt/prueba-tecnica-eval/cisco-credentials.env`)

1. Copiar [`evaluator/cisco-credentials.example`](evaluator/cisco-credentials.example) → [`evaluator/cisco-credentials.env`](evaluator/cisco-credentials.env) (gitignored).
2. Completar `ANSIBLE_CISCO_USER`, `ANSIBLE_CISCO_PASSWORD` y `ANSIBLE_CISCO_ENABLE`.
3. Usuario, contraseña y enable **no** van en `group_vars` para que el participante no las vea.
4. El install las sube a `/opt/prueba-tecnica-eval/cisco-credentials.env` (`640`, grupo `ubuntu`).
5. El participante ejecuta playbooks con **`lab-ansible`** (usuario `demo`).

### Import Zabbix (hosts)

Archivo: [`zabbix/hosts-demo-prueba-tecnica.yaml`](zabbix/hosts-demo-prueba-tecnica.yaml) — ver [`zabbix/README.md`](zabbix/README.md).

### Verificación rápida (evaluador)

- [ ] Usuario `demo` existe (`id demo` en la VM)
- [ ] Clave en `host-setup/keys/demo-access`; participante: `ssh -i … demo@<host>`
- [ ] `evaluator/cisco-credentials.env` desplegado en `/opt/prueba-tecnica-eval/`
- [ ] `lab-check` en la VM (como `ubuntu`) tras el install
- [ ] `/home/demo/prueba-tecnica/.env.prueba-tecnica` con las cuatro variables `ZABBIX_*`
- [ ] Zabbix: 3 hosts; alerta SNMP solo en `SW-Prod-Edge1`
- [ ] `disparar-incidente` (como `demo`) / `restaurar-incidente` probados

Preparación general del entorno: [`docs/guia-evaluador.md`](../docs/guia-evaluador.md).

---

## Layout en el servidor

| Ruta | Quién | Uso |
| --- | --- | --- |
| `/home/demo/prueba-tecnica/` | Participante (`demo`) | Directorio de trabajo (app, ansible, .env) |
| `/home/demo/prueba-tecnica/ansible/` | Participante | Inventario + `playbooks/participante/` |
| `/home/demo/prueba-tecnica/scripts/` | Participante | `lab-ansible`, aliases SSH (`aliases.sh`) |
| `/home/demo/prueba-tecnica/.env.prueba-tecnica` | Participante | API Zabbix (`ZABBIX_*`) |
| `/opt/prueba-tecnica-eval/cisco-credentials.env` | Sistema | Ansible cambio Cisco (`lab-ansible`, incidente) |
| `/opt/prueba-tecnica-eval/` | Evaluador (`ubuntu`) | Falla/rollback (750 root:ubuntu — **sin acceso demo**) |
| `/usr/local/bin/disparar-incidente` | Participante | `disparar-incidente` (Parte 3, sin sudo) |
| `/opt/prueba-tecnica-eval/bin/lab-check`, `lab-reset`, `restaurar-incidente` | Evaluador (ubuntu) | Solo grupo ubuntu; no en PATH de demo |
| `host-setup/scripts/participant/` | Repo local | `lab-ansible`, `aliases.sh` → se despliegan a `/home/demo/...` |
| `host-setup/scripts/deploy/` | Repo local | install, resumen post-install, `lab-check`, `lab-reset` |

## Participante (SSH `demo@…`)

```bash
ssh-rtr | ssh-core | ssh-edge
lab-ansible mi-fix.yml    # playbooks en playbooks/participante/
disparar-incidente        # Parte 3 — una vez
```

## Evaluador (sesión `ubuntu@…`, PATH en `/opt/prueba-tecnica-eval/bin`)

```bash
lab-check
restaurar-incidente
lab-reset

# Editar falla antes de la prueba (incident.conf es legible por ubuntu)
nano /opt/prueba-tecnica-eval/incident.conf
```

`restaurar-incidente` incluye rollback de red y borrado del lock `state/incident.triggered`.

## Router IOSv

`python/sitecustomize.py` se instala en site-packages del sistema (KEX legacy Paramiko); no se copia al home del participante.
