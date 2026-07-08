# Import Zabbix — hosts de la prueba técnica

Archivo: **`hosts-demo-prueba-tecnica.yaml`**

## Contenido

| Host | IP | SNMP en Zabbix | Notas |
| --- | --- | --- | --- |
| `RTR-Prod-Gateway1` | `10.0.0.80` | `snmp-demo` | OK |
| `SW-Prod-Core1` | `10.0.0.81` | `snmp-demo` | OK |
| `SW-Prod-Edge1` | `10.0.0.82` | `snmp-bad` | **Baseline Parte 2** — incorrecta solo en Zabbix |

Template requerido en Zabbix: **Cisco IOS by SNMP**. Grupo: **demo**.

## Importar

1. Zabbix UI → **Configuration** → **Hosts** → **Import**
2. Seleccionar `hosts-demo-prueba-tecnica.yaml`
3. Confirmar que los 3 hosts quedan en el grupo `demo`
4. Verificar que `SW-Prod-Edge1` tenga macro `{$SNMP_COMMUNITY}` = `snmp-bad`

# Crear usuario y token API

1. Zabbix UI → **Administration** → **Users** → **Create user**: `demo`
2. Zabbix UI → **Administration** → **General** → **API Token** → **Create token**: `demo Token`
3. En la VM demo: `host-setup/env.prueba-tecnica` (local) se despliega a `~/prueba-tecnica/.env.prueba-tecnica` con `install-on-demo-vm.sh` — ver [plantilla-evaluador](../../docs/plantilla-evaluador.md).
