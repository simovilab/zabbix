# zabbix
Zabbix server
# 📘 Zabbix

:contentReference[oaicite:0]{index=0} es una plataforma de monitoreo open source que permite supervisar servidores, redes, aplicaciones, bases de datos, máquinas virtuales y servicios en la nube.

Su función principal es detectar problemas y alertar automáticamente a los administradores mediante notificaciones, ayudando a reaccionar rápidamente ante fallos o caídas. Además, ofrece paneles web, reportes y visualización de datos para analizar el estado y rendimiento de la infraestructura IT.

Se caracteriza por ser escalable, flexible y gratuita, por lo que puede ser utilizada tanto en pequeñas empresas como en grandes organizaciones.

---

# 📚 Glosario

## 🏗️ Infraestructura

### 🖥️ Zabbix Server
Proceso central que ejecuta el monitoreo, calcula triggers, envía notificaciones y almacena datos.

### ⚙️ Zabbix Agent / Agent 2
Proceso instalado en el host monitorizado para recolectar métricas locales.

- Agent clásico: monitoreo básico
- Agent 2: soporta plugins y extensiones modernas

### 🔄 Zabbix Proxy
Recolecta datos en nombre del server, distribuyendo la carga de procesamiento.

### 🧩 Host
Cualquier dispositivo físico, virtual, aplicación o servicio con parámetros monitorizados.

### 📂 Host Group
Agrupación lógica de hosts, usada para organización y permisos de acceso.

### 🌐 Frontend
Interfaz web de Zabbix para visualizar y gestionar el monitoreo.

---

## 📊 Recolección de datos

### 📌 Item
Una métrica concreta recolectada desde un host.

Ejemplos:
- uso de CPU
- memoria RAM
- espacio en disco
- tráfico de red

### 🛠️ Value Preprocessing
Transformación aplicada al valor de una métrica antes de almacenarse en la base de datos.

Ejemplos:
- conversión de unidades
- extracción con regex
- JSONPath
- JavaScript

### 🌍 Web Scenario
Conjunto de peticiones HTTP utilizadas para verificar disponibilidad y rendimiento de un sitio web.

---

## 🚨 Alertas y eventos

### ⚠️ Trigger
Expresión lógica que define una condición o umbral.

Pasa a estado **Problem** cuando la condición se cumple.

### 📅 Event
Ocurrencia registrada por Zabbix que representa un cambio relevante en el sistema.

### 🔴 Problem
Estado activo de un trigger cuando existe una incidencia.

Puede actualizarse con:
- comentarios
- severidad
- reconocimiento
- cierre manual

### 📣 Action / Escalation
Respuesta automática definida para un evento.

Ejemplos:
- enviar email
- ejecutar script
- webhook
- comando remoto

La *escalation* define el orden y tiempos de ejecución.

### 🔗 Event Correlation
Permite relacionar eventos y cerrar problemas automáticamente según reglas definidas.

### 🏷️ Event Tag
Etiqueta asociada a eventos y problemas, útil para:
- correlación
- automatización
- filtrado
- permisos

---

## 🤖 Plantillas y automatización

### 📦 Template
Conjunto reutilizable de:
- items
- triggers
- gráficas
- discovery rules

aplicable a múltiples hosts.

### 🔍 Low-Level Discovery (LLD)
Descubrimiento automático de entidades dentro de un host.

Ejemplos:
- interfaces de red
- discos
- filesystems
- contenedores

### 🧮 Macro
Variable reutilizable cuyo valor depende del contexto.

Ejemplo:

```txt
{$CPU.UTIL.MAX}