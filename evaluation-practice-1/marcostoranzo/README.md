# Práctica 1: Desarrollo y despliegue de servicios de monitorización en Cloud Computing usando contenedores

## Información

- **Nombre**: Marcos Toranzo
- **Grupo de prácticas**: 1
- **Perfil de GitHub**: `marcos-toranzo`

## Descripción

### Objetivos de la práctica

- Crear servicios interconectados usando contenedores.

- Conocer el despliegue de servicios en contenedores usando docker, docker-compose y kubernetes.

- Gestionar la escalabilidad de los servicios.

- Implementar una estructura de contenedores para que provea de alta disponibilidad.

- Soporte del servicio para múltiples usuarios al mismo tiempo.

- Utilización de servicios de monitorización en Cloud Computing.

### Descripción del trabajo de la práctica

Este trabajo consiste en proveer de un sistema de monitorización basado en Prometheus que permita capturar las métricas, insertarlas en su base de datos y publicarlas para poder visualizarlas a través de Grafana. Además de esto se requiere de un servicio que ofrezca alta disponibilidad para al menos uno de los servicios anteriores (por ejemplo Grafana o bien Prometheus).

Para esta práctica evaluable se desplegarán los siguientes servicios:

- Para los servicios de monitorización y exportación de métricas se usanrán las herramientas y servicios proporcionados por el motor de monitorización Prometheus (https://prometheus.io/).

- Para el servicio de visualización de métricas se usará Grafana (https://grafana.com/).

- Para el servicio de alta disponibilidad se usará HAProxy u otro servicio similar (http://www.haproxy.org/).

### Servicios desplegados

- **Prometheus server**: corre sobre `9090:9090`, targets: él mismo y los dos node exporters. Configuración más detallada en [prometheus.yml](prometheus/prometheus.yml) y [docker-compose.yml](docker-compose.yml).
- **Prometheus node exporters**: dos de ellos: `node-exporter1` y `node-exporter2`, corriendo sobre `9100:9100` y `9200:9100`, respectivamente. Configuración más detallada en [docker-compose.yml](docker-compose.yml).
- **Grafana**: dos de ellos: `grafana1` y `grafana2`, corriendo sobre `3000:3000` y `3100:3000`, respectivamente. Usan [grafana.ini](grafana/grafana.ini) para la configuración y [all.yml](grafana/provisioning/datasources/all.yml) para especificar automáticamente dónde buscar los datos provenientes de Prometheus. Configuración más detallada en [docker-compose.yml](docker-compose.yml).
- **HAProxy**: corre sobre `8080:80`. Usa dos servidos backend referenciando a los servidores de Grafana. Configuración más detallada en [haproxy.cfg](haproxy/haproxy.cfg) y [docker-compose.yml](docker-compose.yml).

## Conclusiones

Se pudo interactuar con herramientas de virtualización de entornos como los contenedores Docker. Se pudo apreciar las facilidades que brinda este tipo de herramientas ya que nos permite transportar todo el entorno necesario para el despliegue de nuestro servicio sin esperar que el servidor en el que sera desplegado cuente con todas las dependencias necesarias para ejecutarlo, así como la facilidad para lanzar varios servicios al mismo tiempo e interconectarlos.

## Notas

No se pudo hacer uso de Kubernetes, implementar cada servicio de forma independiente sin el uso de `docker-compose` o lograr una correcta implementación del HAProxy, ya que no se logró implementar antes del plazo de entrega debido a poco tiempo disponible (personal), mala planificación y subestimación del tiempo necesario para realizar la tarea. No es un intento de excusa, solo quiero dejar claro las limitaciones de mi implementación :). Para la entrega en GitHub espero (si es posible) tener esas implementaciones listas para la defensa.

Para levantar el proyecto se debe ejecutar `docker-compose up` en la carpeta root.
