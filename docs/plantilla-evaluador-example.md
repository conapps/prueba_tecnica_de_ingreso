# Notas del evaluador — Prueba técnica DevOps (formato)

Uso **interno**. No entregar al participante.

1. Copiar este archivo a `plantilla-evaluador.md`.
2. Completar junto con [plantilla-entrega.md](plantilla-entrega.md) (la que sí recibe el participante).

---

## Zabbix


| Campo               | Valor |
| ------------------- | ----- |
| URL                 |       |
| Usuario UI          |       |
| Contraseña UI       |       |
| API Token           |       |

> **💡 Nota:** Actualizar estos valores en las variables del archivo `host-setup/env.prueba-tecnica` (copiar desde `env.example`) y ejecutar el install en la VM demo para que se carguen en el servidor.

---

## Zabbix — monitoreo


| Host Zabbix | Community SNMP en Zabbix          | Notas                                                          |
| ----------- | --------------------------------- | -------------------------------------------------------------- |
|             | *(correcta)*                      |                                                                |
|             | *(correcta)*                      |                                                                |
|             | *(incorrecta — baseline Parte 2)* | Solo en Zabbix; en el equipo la community de la entrega al participante |


---

## Ansible


| Campo             | Valor |
| ----------------- | ----- |
| Inventario        | `~/prueba-tecnica/ansible/` |
| Archivo local     | `host-setup/evaluator/cisco-credentials.env` (desde `cisco-credentials.example`) |
| Archivo en servidor | `/opt/prueba-tecnica-eval/cisco-credentials.env` |
| Rollback / reset escenario | `restaurar-incidente` |
| Config incidente  | `/opt/prueba-tecnica-eval/incident.conf` |


---

## Plan de la prueba


| Campo                                  | Valor |
| -------------------------------------- | ----- |
| Baseline Parte 2 (alerta preexistente) |       |
| Falla planificada Parte 3              | Configurada en `incident.conf` — participante ejecuta `disparar-incidente` |
| Rollback Parte 3                       | `restaurar-incidente` (ubuntu) |
| Observaciones                          |       |
