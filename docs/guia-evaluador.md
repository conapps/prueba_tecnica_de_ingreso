# Guía del evaluador — Prueba técnica DevOps

Documento interno. La consigna para el participante está en [consigna-participante.md](consigna-participante.md).

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

- 3 equipos Cisco funcionales en el lab (1 router + 2 switches).
- Conectados entre sí según la topología del entorno.
- SSH habilitado en los tres.
- SNMP habilitado en los equipos para monitoreo desde Zabbix.

### Zabbix

Deben existir **3 hosts** visibles para la prueba (mismos nombres que en la [plantilla de entrega](plantilla-entrega.md)):

1. Router Cisco IOS.
2. Switch Cisco IOS (core).
3. Switch Cisco IOS (edge) como equipo ficticio/simulado.

**Baseline Parte 2:** en **uno** de los switches (típicamente el edge), configurar en Zabbix una community SNMP **incorrecta** respecto al equipo real. El equipo en CML sigue operativo; la alerta aparece solo en monitoreo. **No** es la falla de la Parte 3.

**Requisitos:**


| Requisito        | Detalle                                                 |
| ---------------- | ------------------------------------------------------- |
| Equipos en CML   | Los 3 funcionales; interfaces descubiertas en Zabbix    |
| Baseline Parte 2 | Un switch con community SNMP errónea **solo en Zabbix** |
| Independencia    | Los 3 monitoreables por separado                        |
| Falla simulable  | Posibilidad de corte o problema en enlace de datos      |
| Usuario prueba   | Solo ve esos 3 hosts; sin acceso al resto del ambiente  |
| API token        | Lectura: hosts, problemas, triggers, eventos            |


### Servidor Linux en OCI


| Componente   | Requisito                                           |
| ------------ | --------------------------------------------------- |
| Acceso       | Credenciales SSH separadas para evaluador y participante |
| Software     | Ansible; Docker preinstalado (opcional — stack libre) |
| Conectividad | Zabbix, equipos Cisco (SSH), salida HTTP/HTTPS      |
| Ansible      | Inventario/vars con permisos de **cambio** en Cisco |
| SSH lectura  | Credenciales separadas solo diagnóstico             |


---

## 3. Datos a completar y entregar

Completar **[plantilla-entrega.md](plantilla-entrega.md)** (participante) y **[plantilla-evaluador.md](plantilla-evaluador.md)** (interno) al inicio de cada prueba. 

Formatos vacíos: [plantilla-entrega-example.md](plantilla-entrega-example.md), [plantilla-evaluador-example.md](plantilla-evaluador-example.md).

Al participante hay que entregarle: [consigna](consigna-participante.md) + **plantilla-entrega** + archivo **`host-setup/keys/demo-access`**.

```bash
bash host-setup/install-on-demo-vm.sh demoN.dominio
bash host-setup/scripts/deploy/print-install-summary.sh demoN.dominio
```

---

## 4. Consigna (resumen)

Página web que consulte la API de Zabbix y muestre estado y alertas de 3 equipos; luego diagnóstico y remediación con Ansible ante falla simulada.

**Documento para el participante:** [consigna-participante.md](consigna-participante.md)

---

## 5. Parte 1 — Página de estado de equipos

### Pedido

- Nombre del equipo.
- Estado general / disponibilidad.
- Marca visual: Disponible / No disponible / Desconocido.

### Condiciones

- Corre en servidor Linux (stack libre: Docker, Podman, proceso en host, etc.).
- Accesible por navegador; al cierre de la prueba el participante informa URL/puerto.
- Sin auth en la página; sin diseño elaborado.

### Checkpoint evaluador (opcional)

El participante **no** está obligado a avisar al terminar la Parte 1. Podés revisar cuando quieras o al cierre de la Parte 3.

---

## 6. Parte 2 — Visualización de alertas

### Pedido

- Cantidad de problemas por equipo en tabla resumen.
- Detalle: equipo, alerta, severidad, desde, estado.

### Condiciones

- Solo hosts de la prueba.
- API Zabbix; refresh manual o automático.

### Checkpoint evaluador (opcional)

Igual que la Parte 1: el participante puede encadenar Parte 2 → Parte 3 sin avisarte. Validá baseline SNMP en Edge cuando revises o antes de la verificación final.

---

## 7. Parte 3 — Simulación de falla y troubleshooting

### Activación del incidente (self-service)

El participante ejecuta en el servidor:

```bash
disparar-incidente
```

- **Sin escribir `sudo`**: el wrapper en `/usr/local/bin/disparar-incidente` usa `sudo -n` solo para el script en `/opt` (NOPASSWD en sudoers).
- Automatismo en `/opt/prueba-tecnica-eval/` (root; sin lectura directa para `demo`).
- Salida al participante: **solo** el mensaje de confirmación (detalle Ansible en `/opt/prueba-tecnica-eval/state/ansible.log`, evaluador).
- El usuario `demo` **no** tiene sudo libre (solo los dos comandos whitelisteados). No compartir `ubuntu` al participante.
- Configuración del incidente: `/opt/prueba-tecnica-eval/incident.conf` (evaluador).
- **Restaurar escenario (solo evaluador):** `restaurar-incidente` — rollback + borrar `state/incident.triggered` (no hace falta `rm` manual).

### Tipo de falla (configurar en `incident.conf`)


| Opción | Acción                      | Rollback         |
| ------ | --------------------------- | ---------------- |
| **A**  | `shutdown` en interfaz      | `no shutdown`    |
| **B**  | Eliminar ruta en router     | Restaurar ruta   |
| **C**  | Cortar enlace router–switch | Restaurar enlace |


La falla debe ser **conocida** por el evaluador y con **rollback** documentado. Es **distinta** de la alerta baseline de Parte 2 (SNMP mal configurado solo en Zabbix).

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

El participante **no** debe conocer la falla de antemano ni leer los playbooks en `/opt`.

### Comandos en la VM demo (evaluador)

Completar antes `host-setup/env.prueba-tecnica` y `host-setup/evaluator/cisco-credentials.env` (ver [host-setup/README.md](../host-setup/README.md)).

**Desde tu máquina** (repo `prueba_tecnica_de_ingreso`), desplegar o actualizar el entorno del participante:

```bash
bash host-setup/install-on-demo-vm.sh demoN.dominio
```

**En la VM** — evaluador: SSH como **`ubuntu`**. Participante: SSH como **`demo`**.

Tras el install, en sesión **`ubuntu`**: `lab-check`, `lab-reset` y `restaurar-incidente` (PATH en `/opt/prueba-tecnica-eval/bin/` vía `/etc/profile.d` y `~/.zshrc`). En sesión **`demo`**: `lab-ansible` y `disparar-incidente`. **`demo` no accede a `/opt/prueba-tecnica-eval/` ni ejecuta comandos de evaluador.**

```bash
lab-check                  # ping + Ansible + SNMP (chequeo rápido del lab)
disparar-incidente         # probar activación Parte 3 (participante usa este mismo comando)
restaurar-incidente        # rollback + borrar lock para otro `disparar-incidente`
lab-reset                  # borrar playbooks en `playbooks/participante/` del participante actual
```

| Comando | Quién | Cuándo |
| --- | --- | --- |
| `lab-check` | Evaluador | Tras `install-on-demo-vm.sh` y antes de recibir al participante |
| `disparar-incidente` | Participante (`demo`; evaluador puede probar) | Inicio Parte 3 |
| `restaurar-incidente` | Evaluador | Tras Parte 3: rollback red + lock para otro `disparar-incidente` |
| `lab-reset` | Evaluador | Borrar playbooks en `playbooks/participante/` del participante actual |

El script `install-on-demo-vm.sh` es para la **primera preparación** de la VM o cuando **actualizás** algo del repo `host-setup/` (inventario, scripts, `/opt`, credenciales).


| Qué restaura | Cómo |
| --- | --- |
| Falla simulada Parte 3 (ej. interfaz down) | `restaurar-incidente` |
| Lock `disparar-incidente` (una vez por prueba) | `restaurar-incidente` (incluye `rm` del lock) |
| Playbooks del participante | `lab-reset` |
| Inventario, scripts, `/opt`, `/home/demo/prueba-tecnica/.env.prueba-tecnica` | Sin cambios (siguen del install) |

**Reset fuerte** (opcional): `bash host-setup/install-on-demo-vm.sh demoN...` resincroniza en `/home/demo/prueba-tecnica/` solo `ansible/` y `scripts/` (participante). Install, `env.example`, `python/` y scripts de evaluador **no** van al home de `demo`.

| Ruta | Uso |
| --- | --- |
| `/opt/prueba-tecnica-eval/incident.conf` | `FAIL_HOST`, `FAIL_INTERFACE` |
| `/usr/local/bin/disparar-incidente` | Participante — `disparar-incidente` (una vez, sin sudo) |
| `/opt/prueba-tecnica-eval/bin/restaurar-incidente` | Evaluador — `restaurar-incidente` (rollback + borrar lock) |

Detalle de instalación: [host-setup/README.md](../host-setup/README.md).

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


| Criterio                         | Peso sugerido |
| -------------------------------- | ------------- |
| Uso de herramientas de IA        | 30%           |
| Monitoreo y troubleshooting      | 25%           |
| Infraestructura y automatización | 20%           |
| Desarrollo de la solución        | 15%           |
| Comunicación                     | 10%           |


### Uso de IA (30%)

- Uso práctico y ordenado; buen contexto en prompts.
- No copiar comandos peligrosos sin entender.
- Validar, iterar, explicar.

### Monitoreo y troubleshooting (25%)

- Interpretar alertas; distinguir alerta baseline (Zabbix) vs falla simulada Parte 3; SSH diagnóstico; remediación Ansible; verificar resolución.

### Infraestructura y automatización (20%)

- Linux, runtime libre, logs; Ansible en Cisco; **sin** cambios manuales SSH.

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
- No confundir la alerta baseline (SNMP en Zabbix) con el incidente de Parte 3.
- No validar resolución.
- Evitar Ansible.

---

## 13. Checklist pre-prueba (evaluador)

Instalación en la VM e import de hosts: [host-setup/README.md](../host-setup/README.md).

- [ ] CML: 3 equipos funcionales; SSH y SNMP en cada uno (`10.0.0.80`–`82`).
- [ ] VM demo: `make up-services` / `start` con `instance_suffix=N` (rol `demo`: usuario Linux **`demo`**, Docker, Ansible).
- [ ] Zabbix: `make up` + token usuario `demo`; import [`hosts-demo-prueba-tecnica.yaml`](../host-setup/zabbix/hosts-demo-prueba-tecnica.yaml).
- [ ] VM demo: `bash host-setup/install-on-demo-vm.sh demoN...`; `env.prueba-tecnica` + `cisco-credentials.env` desplegados.
- [ ] Clave participante: `host-setup/keys/demo-access` (misma en todo el lab)
- [ ] En la VM (ubuntu): `lab-check` OK; participante puede SSH como `demo`.
- [ ] Verificar baseline: alerta en Zabbix vs equipo real operativo por SSH/SNMP.
- [ ] VM Linux: Ansible, conectividad, rutas/firewall OK (Docker opcional para el participante).
- [ ] Inventario Ansible (lectura vs cambio) probado.
- [ ] Incidente self-service: `disparar-incidente` (participante) probado; `restaurar-incidente` (evaluador) OK.
- [ ] Consigna enviada: [consigna-participante.md](consigna-participante.md).
- [ ] Plantilla de entrega completada: [plantilla-entrega.md](plantilla-entrega.md).
- [ ] Notas del evaluador completadas: [plantilla-evaluador.md](plantilla-evaluador.md).

---

## 15. Recomendación de conducción

Prueba en **3 bloques** bien visibles:

1. **Construcción** — API Zabbix + estado.
2. **Observabilidad** — problemas/alertas.
3. **Operación** — falla + Ansible.

Entre bloques: validar Parte 2; el participante activa el incidente con `disparar-incidente` (está en la consigna).