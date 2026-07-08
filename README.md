# Prueba técnica de ingreso — DevOps (IA / Infraestructura)

Material para la **prueba técnica de ingreso** del área de trabajo, con foco en monitoreo (Zabbix), automatización (Ansible), troubleshooting y uso responsable de herramientas de IA.

## Documentación

| Documento | Audiencia | Descripción |
| --- | --- | --- |
| **[Consigna para el participante](docs/consigna-participante.md)** | Participante | Texto listo para entregar al inicio de la prueba (Partes 1, 2 y 3). |
| **[Guía del evaluador](docs/guia-evaluador.md)** | Equipo interno | Entorno, criterios, fallas simuladas, automatismos y checklist. |
| **[Plantilla de entrega](docs/plantilla-entrega.md)** | Participante | Accesos de esta prueba (enviar con la consigna). |
| **[Plantilla de entrega (formato)](docs/plantilla-entrega-example.md)** | Equipo interno | Formato vacío para otra prueba. |
| **[Notas del evaluador](docs/plantilla-evaluador.md)** | Equipo interno | Zabbix, Ansible y plan de fallas (instancia actual). |
| **[Notas del evaluador (formato)](docs/plantilla-evaluador-example.md)** | Equipo interno | Formato vacío. |
| **[Host setup (VM demo)](host-setup/README.md)** | Equipo interno | Bootstrap completo: CML, OCI, Zabbix, scripts en la VM. |

## Resumen de la prueba

La prueba se desarrolla en **3 bloques**:

1. **Construcción** — Página web que consume la API de Zabbix y muestra el estado de 3 hosts.
2. **Observabilidad** — Extensión de la página para mostrar problemas/alertas activos.
3. **Operación** — Diagnóstico de una falla simulada y remediación mediante **Ansible** (no cambios manuales en Cisco).

## Entorno (referencia rápida)

- **CML**: 3 equipos Cisco; baseline = SNMP mal configurado solo en Zabbix en un switch.
- **Red**: Cisco CML (router + 2 switches, SSH y SNMP).
- **Servidor Linux (OCI)**: usuario SSH **`demo`** (participante), Ansible, Docker opcional; conectividad a Zabbix y Cisco. Evaluador: **`ubuntu`**.

Para detalle de infraestructura, credenciales, criterios de evaluación y procedimientos del evaluador, ver [guía del evaluador](docs/guia-evaluador.md).
