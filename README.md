# Prueba técnica de ingreso — DevOps Jr. (IA / Infraestructura)

Material para la **prueba técnica de ingreso** del área de trabajo, con foco en monitoreo (Zabbix), automatización (Ansible), troubleshooting y uso responsable de herramientas de IA.

## Documentación

| Documento | Audiencia | Descripción |
| --- | --- | --- |
| **[Consigna para el participante](docs/consigna-participante.md)** | Candidato/a | Texto listo para entregar al inicio de la prueba (Partes 1, 2 y 3). |
| **[Guía del evaluador](docs/guia-evaluador.md)** | Equipo interno | Entorno, criterios, fallas simuladas, automatismos y checklist. |

## Resumen de la prueba

La prueba se desarrolla en **3 bloques**:

1. **Construcción** — Página web que consume la API de Zabbix y muestra el estado de 3 equipos.
2. **Observabilidad** — Extensión de la página para mostrar problemas/alertas activos.
3. **Operación** — Diagnóstico de una falla simulada y remediación mediante **Ansible** (no cambios manuales en Cisco).

## Entorno (referencia rápida)

- **Zabbix**: 3 hosts (router Cisco, switch Cisco, equipo ficticio con alerta SNMP).
- **Red**: Cisco CML (router + switch, SSH y SNMP).
- **Servidor Linux (OCI)**: Docker, Ansible, conectividad a Zabbix y equipos Cisco.

Para detalle de infraestructura, credenciales, criterios de evaluación y procedimientos del evaluador, ver [guía del evaluador](docs/guia-evaluador.md).
