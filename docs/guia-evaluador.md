# Guía del evaluador — Prueba técnica DevOps

Documento interno. La consigna para el candidato está en [consigna-participante.md](consigna-participante.md).

---

## 1. Objetivo de la prueba

Evaluar cómo la persona se desenvuelve usando herramientas de IA para resolver una necesidad técnica relacionada con infraestructura, automatización, monitoreo y troubleshooting.

La prueba **no** busca evaluar solamente conocimientos técnicos puros, sino también:

- Cómo interpreta un entorno técnico desconocido.
- Cómo usa IA para avanzar, investigar, generar código o automatizaciones.
- Cómo valida lo que la IA propone.
- Cómo interactúa con una herramienta vía API.
- Cómo se conecta a equipos de red por SSH.
- Cómo diagnostica una alerta.
- Cómo propone o ejecuta una remediación mediante Ansible.
- Cómo comunica avances y bloqueos.

---

## 2. Entorno preparado para la prueba

### Infraestructura de red (Cisco CML)

- 1 router Cisco IOS.
- 1 switch Cisco IOS.
- Ambos conectados entre sí.
- SSH habilitado en ambos.
- SNMP habilitado para monitoreo desde Zabbix.

### Zabbix

Deben existir **3 hosts** visibles para la prueba:

1. Router Cisco IOS.
2. Switch Cisco IOS.
3. Equipo ficticio/simulado.

**Requisitos:**

| Requisito | Detalle |
| --- | --- |
| Equipos reales | monitoreados; todas las interfaces descubiertas |
| Equipo ficticio | con al menos una alerta SNMP activa (referencia para Parte 2) |
| Independencia | Router y switch reales monitoreables por separado |
| Falla simulable | Posibilidad de corte o problema entre router y switch |
| Usuario prueba | Solo ve esos 3 hosts; sin acceso al resto del ambiente |
| API token | Lectura: hosts, problemas, triggers, eventos |

### Servidor Linux en OCI

| Componente | Requisito |
| --- | --- |
| Acceso | SSH para el participante |
| Software | Docker, Ansible |
| Conectividad | Zabbix, equipos Cisco (SSH), salida HTTP/HTTPS |
| Ansible | Inventario/vars con permisos de **cambio** en Cisco |
| SSH lectura | Credenciales separadas solo diagnóstico |

---

## 3. Datos que se entregan al participante

Ver checklist en [consigna-participante.md](consigna-participante.md#qué-te-entregamos-al-iniciar).

**Plantilla de entrega** (completar al inicio):

**Servidor Linux**

| Campo | Valor |
| --- | --- |
| Host | |
| Usuario | |
| Puerto SSH | |
| Notas | |

**Ansible (cambios)**

| Campo | Valor |
| --- | --- |
| Inventario | |
| Grupo / vars | |

**Zabbix**

| Campo | Valor |
| --- | --- |
| URL | |
| Usuario | |
| Contraseña | |
| Token | |

**Equipos**

| Campo | Valor |
| --- | --- |
| Nombre | |
| IP | |
| Usuario | |
| Contraseña | |
| SNMPv2 | |

| Campo | Valor |
| --- | --- |
| Nombre | |
| IP | |
| Usuario | |
| Contraseña | |
| SNMPv2 | |

| Campo | Valor |
| --- | --- |
| Nombre | |
| IP | |
| Usuario | |
| Contraseña | |
| SNMPv2 | |

---

## 4. Consigna (resumen)

Página web que consulte la API de Zabbix y muestre estado y alertas de 3 equipos; luego diagnóstico y remediación con Ansible ante falla simulada.

**Documento para el candidato:** [consigna-participante.md](consigna-participante.md)

---

## 5. Parte 1 — Página de estado de equipos

### Pedido

- Nombre del equipo.
- Estado general / disponibilidad.
- Marca visual: Disponible / No disponible / Desconocido.

### Condiciones

- Corre en servidor Linux (host o contenedor).
- Accesible por navegador; participante informa URL/puerto.
- Sin auth en la página; sin diseño elaborado.

### Checkpoint evaluador

> Cuando termines esta primera parte, avisame y mostrame cómo acceder a la página.

---

## 6. Parte 2 — Visualización de alertas

### Pedido

- Cantidad de problemas por equipo en tabla resumen.
- Detalle: equipo, alerta, severidad, desde, estado.

### Condiciones

- Solo hosts de la prueba.
- API Zabbix; refresh manual o automático.

### Checkpoint evaluador

> Cuando termines esta segunda parte, avisame. Luego vamos a simular un problema.

---

## 7. Parte 3 — Simulación de falla y troubleshooting

### Acción del evaluador (elegir una)

| Opción | Acción | Rollback |
| --- | --- | --- |
| **A** | `shutdown` en interfaz | `no shutdown` |
| **B** | Eliminar ruta en router | Restaurar ruta |
| **C** | Cortar enlace router–switch | Restaurar enlace |

La falla debe ser **conocida** por el evaluador y con **rollback** documentado.

### Pedido al participante

> Ahora hay un problema en el entorno. Usá Zabbix, tu página y SSH de solo lectura para analizar qué pasa. Explicá el problema y cómo lo resolverías. Si estás seguro, aplicá la corrección con **Ansible**, no con cambios manuales por SSH.

### Qué debería hacer el participante

- Ver alerta en su página y validar en Zabbix.
- SSH solo lectura: interfaces, rutas, conectividad.
- Explicar causa y remediación.
- Playbook Ansible + ejecutar + confirmar recuperación.

---

## 8. Expectativas Parte 3 (detalle)

- No es obligatorio saber Cisco de memoria; sí **validar** lo que ejecuta.
- SSH lectura **solo diagnóstico**.
- Remediación **obligatoria vía Ansible** con credenciales de automatización.

---

## 9. Automatismos de falla y rollback (evaluador)

El participante **no** debe conocer la falla de antemano.

### Ejemplo Ansible — generar falla (interfaz)

```yaml
# fail_interface.yml (ejemplo)
- name: Apagar interfaz en router
  cisco.ios.ios_config:
    lines:
      - shutdown
    parents: "interface {{ fail_interface }}"
```

### Ejemplo Ansible — rollback

```yaml
# rollback_interface.yml (ejemplo)
- name: Levantar interfaz
  cisco.ios.ios_config:
    lines:
      - no shutdown
    parents: "interface {{ fail_interface }}"
```

**Flujo sugerido:**

1. Ejecutar playbook de falla.
2. Esperar detección en Zabbix (intervalo + trigger).
3. Pedir al participante que investigue.
4. Tras remediación del participante (o timeout), validar en Zabbix.
5. Si hace falta, rollback evaluador.

---

## 10. Criterios de evaluación

La prueba es **DevOps (IA / Infraestructura)**: la solución de las Partes 1 y 2 es **simple** a propósito (API de Zabbix + una página para mostrarlo). **No** debe ponderarse ese desarrollo por encima del **uso de IA** — nos importa más cómo la usa, valida y comunica (ver consigna) que el diseño o la complejidad del frontend.

| Criterio | Peso sugerido |
| --- | --- |
| Uso de herramientas de IA | 30% |
| Monitoreo y troubleshooting | 25% |
| Infraestructura y automatización | 20% |
| Desarrollo de la solución | 15% |
| Comunicación | 10% |

### Uso de IA (30%)

- Uso práctico y ordenado; buen contexto en prompts.
- No copiar comandos peligrosos sin entender.
- Validar, iterar, explicar.

### Monitoreo y troubleshooting (25%)

- Interpretar alertas; equipo ficticio vs reales; SSH diagnóstico; remediación Ansible; verificar resolución.

### Infraestructura y automatización (20%)

- Linux, Docker, logs, dependencias; Ansible en Cisco; **sin** cambios manuales SSH.

### Desarrollo de la solución (15%)

- Integración con la API de Zabbix (token, consultas correctas); 3 hosts; estado y problemas Parte 2.
- Solución accesible desde el servidor de la prueba (la interfaz puede ser una página web simple).
- Cumplir el pedido basta: **no** subir el puntaje por diseño, framework ni complejidad de frontend.

### Comunicación (10%)

- Avisar fin de cada parte; explicar; bloqueos; preguntas; resumen final.

---

## 11. Qué no ponderar en exceso

- Diseño visual pobre.
- No conocer endpoints Zabbix de memoria.
- No recordar comandos Cisco exactos.
- Framework específico.
- Poca experiencia previa en IA.
- Solución simple pero funcional.

---

## 12. Señales positivas y de alerta

### Positivas

- IA para acelerar + revisión del output.
- Probar API con `curl` antes de la web.
- Variables de entorno para secretos.
- SSH solo diagnóstico; playbook para fix.
- Preguntar antes de automatizaciones con impacto.

### Alerta

- Comandos sin entender; cambios manuales en Cisco.
- No explica su código; no revisa logs.
- No consume API ni con IA.
- Bloqueo sin comunicar.
- Modificar Zabbix sin necesidad.
- Exponer tokens.
- No distinguir equipos ficticios de los reales.
- No validar resolución.
- Evitar Ansible.

---

## 13. Checklist pre-prueba (evaluador)

- [ ] CML: router + switch + SNMP + SSH.
- [ ] Zabbix: 3 hosts (ficticio + alerta SNMP); LLD en reales.
- [ ] Usuario prueba limitado a 3 hosts; token API activo.
- [ ] VM OCI: Docker, Ansible, rutas/firewall OK.
- [ ] Inventario Ansible (lectura vs cambio) probado.
- [ ] Playbooks falla/rollback probados.
- [ ] Consigna impresa o enviada: [consigna-participante.md](consigna-participante.md).
- [ ] Plantilla de credenciales completada.

---

## 15. Recomendación de conducción

Prueba en **3 bloques** bien visibles:

1. **Construcción** — API Zabbix + estado.
2. **Observabilidad** — problemas/alertas.
3. **Operación** — falla + Ansible.

Entre bloques: revisar acceso a la página y confirmar que el equipo ficticio ya muestra su alerta SNMP en Parte 2 antes de simular la falla “real” en Parte 3 (típicamente en un equipo real).
