# Resumen de Zabbix

## ¿Qué es Zabbix?

Zabbix es una solución de observabilidad empresarial de código abierto para IT y OT [1]. Es un sistema de monitoreo integral que permite supervisar prácticamente cualquier elemento de la infraestructura tecnológica, incluyendo redes, servidores, máquinas virtuales, contenedores, aplicaciones, servicios y bases de datos.

### Características principales:

- 100% código abierto y gratuito
- Más de 300,000 implementaciones en más de 190 países [1]
- Bajo costo total de propiedad (sin tarifas de licencia ni cargos por dispositivo)
- Disponible on-premise, en la nube (Zabbix Cloud) o en proveedores cloud de terceros (AWS, Azure, Google Cloud)

## Puertos que utiliza Zabbix

Zabbix utiliza dos puertos TCP principales asignados por IANA [2], [3]:

### Puerto 10050 - Zabbix Agent (pasivo):
- Utilizado cuando el servidor Zabbix se conecta al agente para solicitar métricas [2]
- El agente espera pasivamente las conexiones del servidor o proxy

### Puerto 10051 - Zabbix Server/Trapper (activo):
- Utilizado para chequeos activos, donde el agente se conecta al servidor para enviar datos [2], [3]
- Puerto para comunicación entre servidor y proxy
- Puerto crucial para mantener el flujo de datos entre el servidor y sus agentes [4]

### Otros puertos comunes:
- Puerto 80/443: Interfaz web de Zabbix
- Puerto 3306 o similar: Base de datos (MySQL/PostgreSQL)

## Integración con Docker

Zabbix puede monitorear el motor Docker utilizando su agente 2, que incluye un plugin de monitoreo de Docker integrado [5].

### Características principales de la integración:

**1. Monitoreo nativo sin scripts externos:**
- El template oficial "Docker by Zabbix agent 2" recopila la mayoría de las métricas de una sola vez gracias a la recolección masiva de datos de Zabbix [5]
- Compatible con Zabbix 5.0 en adelante

**2. Métricas monitoreadas:**
- Información general de Docker: número de imágenes disponibles, arquitectura, número total de contenedores [6]
- Métricas específicas por contenedor: memoria, información de red, estado del contenedor [6]
- CPU, disco, uso de red por contenedor

**3. Configuración:**
- Se despliega un contenedor Zabbix Agent2 en el host que ejecuta los otros contenedores [7]
- El usuario que ejecuta Zabbix agent 2 debe tener permisos de acceso al socket de Docker
- Se utiliza descubrimiento de bajo nivel (LLD) para crear automáticamente items, triggers y gráficos para cada contenedor e imagen

**4. Despliegue Docker de Zabbix:**
- Zabbix completo puede ejecutarse en Docker usando docker-compose
- Incluye servidor Zabbix, interfaz web, base de datos y agentes
- Permite monitorear tanto el host Docker como los contenedores que se ejecutan en él

**5. Soporte para orquestadores:**
- Templates oficiales y Helm charts para Kubernetes disponibles [8]
- Soporte para Docker Swarm, Mesos/Marathon

La integración con Docker hace de Zabbix una solución completa para entornos containerizados, permitiendo visibilidad total desde la infraestructura física hasta los microservicios en contenedores.

---

## Referencias (Formato IEEE)

[1] Zabbix LLC, "Zabbix: The enterprise-class open source observability solution," Zabbix.com, 2025. [Online]. Available: https://www.zabbix.com/. [Accessed: Dec. 11, 2025].

[2] Zabbix Documentation Team, "2 Daemons - Zabbix Documentation 7.0," Zabbix.com. [Online]. Available: https://www.zabbix.com/documentation/current/en/manual/appendix/config/daemons. [Accessed: Dec. 11, 2025].

[3] Internet Assigned Numbers Authority (IANA), "Service Name and Transport Protocol Port Number Registry," IANA.org. [Online]. Available: https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml. [Accessed: Dec. 11, 2025].

[4] Zabbix Documentation Team, "Network ports - Zabbix Documentation," Zabbix.com. [Online]. Available: https://www.zabbix.com/documentation/current/en/manual/installation/requirements. [Accessed: Dec. 11, 2025].

[5] Zabbix Documentation Team, "Docker by Zabbix agent 2 - Zabbix Documentation," Zabbix.com. [Online]. Available: https://www.zabbix.com/integrations/docker. [Accessed: Dec. 11, 2025].

[6] Zabbix Blog, "How to monitor Docker containers with Zabbix," Blog.zabbix.com. [Online]. Available: https://blog.zabbix.com/how-to-monitor-docker-containers/. [Accessed: Dec. 11, 2025].

[7] Zabbix Documentation Team, "Docker deployment - Zabbix Documentation," Zabbix.com. [Online]. Available: https://www.zabbix.com/documentation/current/en/manual/installation/containers. [Accessed: Dec. 11, 2025].

[8] Zabbix Documentation Team, "Kubernetes monitoring - Zabbix Documentation," Zabbix.com. [Online]. Available: https://www.zabbix.com/integrations/kubernetes. [Accessed: Dec. 11, 2025].