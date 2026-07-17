# Directorio de trabajo — prueba técnica

Todo lo de la prueba vive acá (`~/prueba-tecnica/`).

## Qué va en cada carpeta

| Ruta | Uso |
|------|-----|
| `app/` | **Tu solución web** (Docker / Compose) — Partes 1 y 2 |
| `ansible/` | Inventario y playbooks Ansible — Parte 3 |
| `ansible/playbooks/participante/` | Tus playbooks (`.yml`); ejecutar con `lab-ansible <archivo.yml>` |
| `scripts/` | `lab-ansible` y aliases SSH — **no modifiques** estos archivos |
| `.env.prueba-tecnica` | Variables `ZABBIX_*` (no hardcodear en el código) |

```bash
~/prueba-tecnica/
├── README.md               # mapa del directorio de trabajo
├── app/                    # tu solución web (Docker)
├── ansible/                # inventario + playbooks (Parte 3)
│   ├── ansible.cfg
│   ├── inventory/
│   │   ├── group_vars/
│   │   ├── host_vars/
│   │   └── hosts.yml
│   └── playbooks/
│       └── participante/   # tus playbooks (.yml) (Parte 3)
├── scripts/                # lab-ansible, aliases — no modifiques estos archivos
└── .env.prueba-tecnica     # variables ZABBIX_*
```
