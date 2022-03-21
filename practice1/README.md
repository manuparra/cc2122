# Práctica 1: Desarrollo y despliegue de servicios de monitorización en Cloud Computing usando contenedores

<!-- vscode-markdown-toc -->
* 1. [Objetivos de la práctica](#Objetivosdelaprctica)
* 2. [Descripción del trabajo a desarrollar en la práctica](#Descripcindeltrabajoadesarrollarenlaprctica)
	* 2.1. [Introducción](#Introduccin)
	* 2.2. [Descripción del trabajo de la práctica](#Descripcindeltrabajodelaprctica)
		* 2.2.1. [Prometheus](#Prometheus)
		* 2.2.2. [Grafana](#Grafana)
		* 2.2.3. [HAProxy](#HAProxy)
	* 2.3. [Implementación de los servicios con contenedores](#Implementacindelosserviciosconcontenedores)
		* 2.3.1. [Docker](#Docker)
		* 2.3.2. [docker-compose](#docker-compose)
		* 2.3.3. [Kubernetes](#Kubernetes)
	* 2.4. [Características de cada servicio para despliegue con contenedores](#Caractersticasdecadaservicioparadespliegueconcontenedores)
		* 2.4.1. [Servicio de `prometheus-server`](#Serviciodeprometheus-server)
		* 2.4.2. [Servicio de `prometheus-node-exporter`](#Serviciodeprometheus-node-exporter)
		* 2.4.3. [Servicio de `grafana`](#Serviciodegrafana)
		* 2.4.4. [Servicio de alta disponibilidad `HAProxy`](#ServiciodealtadisponibilidadHAProxy)
	* 2.5. [Ejemplo de configuración para `docker-compose`](#Ejemplodeconfiguracinparadocker-compose)
* 3. [Entrega de la práctica a traves de PRADO y GitHub. Documentación de la práctica](#EntregadelaprcticaatravesdePRADOyGitHub.Documentacindelaprctica)
	* 3.1. [Plazos de entrega](#Plazosdeentrega)
	* 3.2. [Defensa de la práctica](#Defensadelaprctica)
* 4. [Criterios de evaluación](#Criteriosdeevaluacin)
* 5. [Criterios de evaluación opcionales](#Criteriosdeevaluacinopcionales)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Objetivosdelaprctica'></a>Objetivos de la práctica

- Crear servicios interconectados usando contenedores.
- Conocer el despliegue de servicios en contenedores usando docker, docker-compose y kubernetes.
- Gestionar la escalabilidad de los servicios.
- Implementar una estructura de contenedores para que provea de alta disponibilidad.
- Soporte del servicio para múltiples usuarios al mismo tiempo.
- Utilización de servicios de monitorización en Cloud Computing.

##  2. <a name='Descripcindeltrabajoadesarrollarenlaprctica'></a>Descripción del trabajo a desarrollar en la práctica

###  2.1. <a name='Introduccin'></a>Introducción

El despliegue de servicios en Cloud Computing es fundamental para poner en marcha funcionalidades que permitan tener aplicaciones y software además de infrastructuras con capacidades de soporte para múltiples usuarios y con posibilidades de escalado dinàmico. Aprovechar los recursos que ofrece Cloud Computing de forma flexible es la clave para el correcto diseño de servicios y microservicios interconectados desplegados en la nube (mediante contenedores). 

Hoy en día cada vez existen más dispositivos conectados a Internet y transmitiendo datos de todo tipo a través de los servicios y recursos que provee Cloud Computing. Desde Internet of Things (IoT), hasta la industra, pasando por nuestros hogares, todos ellos están interconectados. Existe una necesidad de monitorizar servicios, infrastructuras y recursos que nos permitan conocer el estado de estos elementos en tiempo real y poder decidir sobre lo que está ocurriendo en términos de consumo, uso de CPU, RAM, o espacio de almacenamiento entre otros. Estos sistemas de monitorización son extremadamente flexibles y muy modulares, lo que los hace excelentes para su desarrollo y despliegue utilizando contenedores y herramientas de orquestación.

En este contexto, el objetivo principal de esta práctica es el despligue de un sistema de monitorización completo compuesto por los siguientes elementos:

- Servicio de captura de métricas.
- Servicio de exportación/publicación de métricas en nodos a monitorizar.
- Servicio de visualización de métricas.
- Servicio de alta disponibilidad para uno de los servicios anteriores.

###  2.2. <a name='Descripcindeltrabajodelaprctica'></a>Descripción del trabajo de la práctica

Este trabajo consiste en proveer de un sistema de monitorización basado en Prometheus que permita capturar las métricas, insertarlas en su base de datos y publicarlas para poder visualizarlas a través de Grafana. Además de esto se requiere de un servicio que ofrezca alta disponibilidad para al menos uno de los servicios anteriores (por ejemplo Grafana o bien Prometheus).

Para esta práctica evaluable se desplegarán los siguientes servicios:

- Para los *servicios de monitorización* y *exportación de métricas* se usanrán las herramientas y servicios proporcionados por el motor de monitorización  Prometheus (https://prometheus.io/).
- Para el servicio de visualización de métricas se usará Grafana (https://grafana.com/). 
- Para el servicio de alta disponibilidad se usará HAProxy u otro servicio similar (http://www.haproxy.org/).

En las siguientes subsecciones se detallan breves descripciones de los servicios individuales.

####  2.2.1. <a name='Prometheus'></a>Prometheus

Prometheus es un conjunto de herramientas de monitorización y alerta de sistemas de código abierto.

Prometheus recopila y almacena sus métricas como datos de series temporales, es decir, la información de las métricas se almacena con la marca de tiempo en la que se registró, junto con pares clave-valor opcionales llamados etiquetas que contienen los valores a monitorizar: CPU, RAM, etc.

Las principales características de Prometheus son
 - un modelo de datos multidimensional con datos de series temporales identificados por el nombre de la métrica y los pares clave/valor
 - no depende del almacenamiento distribuido; los nodos del servidor son autónomos
- la recopilación de series temporales se realiza mediante un modelo de extracción a través de HTTP
- los objetivos se descubren mediante el descubrimiento de servicios o la configuración estática

Prometheus tiene múltiples módulos, nosotros solo usaremos: Prometheus server y Prometheus Node Exporter.

####  2.2.2. <a name='Grafana'></a>Grafana


Grafana es una solución de código abierto para ejecutar analíticas de datos, extraer métricas que den sentido a la cantidad masiva de datos y monitorizar nuestras aplicaciones con la ayuda de  cuadros de mando personalizables.

Grafana se conecta con todas las fuentes de datos posibles, comúnmente conocidas como bases de datos  como Graphite, Prometheus, Influx DB, ElasticSearch, MySQL, PostgreSQL, etc.

La herramienta nos ayuda a estudiar, analizar y supervisar los datos durante un período de tiempo, técnicamente llamado análisis de series de tiempo.

####  2.2.3. <a name='HAProxy'></a>HAProxy

HAProxy es un proxy inverso de código abierto, muy rápido y fiable que ofrece alta disponibilidad, equilibrio de carga y proxy para aplicaciones basadas en TCP y HTTP. A lo largo de los años se ha convertido en el balanceador de carga de código abierto y se incluye en la mayoría de las distribuciones de Linux y últimamente se despliega por defecto en las plataformas en la nube.

###  2.3. <a name='Implementacindelosserviciosconcontenedores'></a>Implementación de los servicios con contenedores

La idea de esta práctica es que el alumno sea capaz de poner en marcha un sistema basado en contenedores  para la monitorización que tenga los 3 servicios (4 en total: 2 de Prometheus[ 1 para node-exporter, y 1 para prometheus server], 1 para Grafana y 1 para HAProxy) citados anteriormente.

Para esta implementación con contenedores, se puede elegir uno de los siguientes métodos de despliegue de servicios para Cloud Computing:

####  2.3.1. <a name='Docker'></a>Docker

Para esta opción de despligue la práctica consistirá en desarrollar cada uno de los contenedores de forma individual para que alberguen cada uno de los servicios siguientes:

- Prometeus server
- Prometeus node-exporter
- Grafana community
- HAProxy

Esta opción implica que los contenedores tienen que ejecutarse sin un orquestador, lo que requerirá que se cree un script para poder desplegar y también bajar todos los servicios. 

####  2.3.2. <a name='docker-compose'></a>docker-compose

Para esta opción se requiere el uso de la herramienta de composición de servicios `docker-compose` que provee Docker. Para ello debes tenerla instalada en tu sistema si ya previamente tienes Docker instalado.

Con esta opción al igual que la anterior se requiere que se incluyan todos los sevicios siguientes dentro del fichero de descripción de servicios a desplegar en `docker-compose`:

- Prometeus server
- Prometeus node-exporter
- Grafana community
- HAProxy

Dada la capacidad de `docker-compose` para automatizar el ciclo de vida de los servicios, solo será necesario crear el fichero `docker-compose.yml` que incluya todos los servicios descritos anteriormente y los demás fichero auxiliares de configuración.

####  2.3.3. <a name='Kubernetes'></a>Kubernetes

Este tipo de despliegue permite automatizar gran parte de las tareas y del ciclo de vida de los servicios, por lo que solo serán necesarios tener activos los servicios siguientes:

- Prometeus server
- Prometeus node-exporter
- Grafana community

El servicio de HAProxy puede se sustituido por el equivalente en kubernetes y que ofrece este tipo de servicio para poder balancear la carga entre los diferentes contenedores de cada `namespace`. 

También para esta forma de despliegue se puede utilizar Helm.

###  2.4. <a name='Caractersticasdecadaservicioparadespliegueconcontenedores'></a>Características de cada servicio para despliegue con contenedores 

Para cada uno de los servicios a desplegar se pide un minimo de configuración que provea de algunos rasgos de escalabilidad y configuración relacionados con Cloud Computing.

####  2.4.1. <a name='Serviciodeprometheus-server'></a>Servicio de `prometheus-server`

Se pide que el servicio de `prometheus-server` tenga:

- Al menos 1-2  contenedores o 1-2 replicas (si se usa `docker-compose` o `Kubernetes`) (dependerá donde uses el balanceador de carga).
- Las métricas deben ser almacenadas en un volumen compartido. Para ello debes utilizar la opción `volumes` en el fichero de `docker-compose`.
- Configurar el tiempo de retención de métricas a 1 semana. Para ello tendrás que utilizar la siguiente directiva: `--storage.tsdb.retention.time` para indicar el periodo.
- Usar la plantilla de configuración siguiente para el servicio de Prometheus y su fichero de configuracion `prometheus.yml`:
```
global:
  scrape_interval: 5s
  scrape_timeout: 10s

scrape_configs:
  - job_name: services
    metrics_path: /metrics
    static_configs:
      - targets:
          - 'prometheus:9090'
          - 'nodeX:9100'
          - 'nodeY:9100'
          - ...
```

Tambien puedes incluir los datos de configuración en el propio `docker-compose.yml` como por ejemplo se indica aquí:

```
...
prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--storage.tsdb.retention.time=XXX' 
    expose:
      - 9090
...
```

- Desde el fichero de despligue debe poder permitir poner disponible al menos 2 servicios, pero podrá ser escalable.

####  2.4.2. <a name='Serviciodeprometheus-node-exporter'></a>Servicio de `prometheus-node-exporter`

- Al menos 2 nodos o 2 contenedores a monitorizar diferentes.
- Utilizar el puerto por defecto 9100
  

####  2.4.3. <a name='Serviciodegrafana'></a>Servicio de `grafana`

- Al menos 2 servicios de Grafana funcionando bajo un balanceador de carga como HAProxy.
- Configuración del servicio que incluya la fuente de datos de `prometheus-sever` de forma automática.
- Incluir un dashboard por defecto para que puedan verse los datos de las métricas. 
- Desde el fichero de despligue debe poder permitir poner disponible al menos 2 servicios, pero podrá ser escalable.

####  2.4.4. <a name='ServiciodealtadisponibilidadHAProxy'></a>Servicio de alta disponibilidad `HAProxy`

- Proveer de 1 servicio de HAProxy que permita balancear la carga de trabajo entre los contenedores disponibles que provean del servicio de Grafana.

###  2.5. <a name='Ejemplodeconfiguracinparadocker-compose'></a>Ejemplo de configuración para `docker-compose`

Un ejemplo de la estructura de servicios que podrá desplegar `docker-compose.yml` es la siguiente:

```
version: '3.7'

volumes:
    prometheus_data: {}
    grafana_data: {}

networks:
  frontend:
  backend:

services:

  prometheus:
    image: prom/prometheus:v2.1.0
    volumes:
      - ./prometheus/:/etc/prometheus/
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      # More configuration here
    ports:
      - 9090:9090
    networks:
      - backend
    restart: always
    ...

  node-exporter:
    image: prom/node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command: 
      - '--path.procfs=/host/proc' 
      - '--path.sysfs=/host/sys'
      - ...
      # Other option to configure here
    ports:
      - 9100:9100
    networks:
      - backend
    restart: always
    ...

  grafana:
    image: grafana/grafana
    user: "472"
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    volumes:
      # Data config here ...
    env_file:
      # Configuration here, using - ./grafana/config.monitoring
    networks:
      - backend
      - frontend
    restart: always
    ...
```

##  3. <a name='EntregadelaprcticaatravesdePRADOyGitHub.Documentacindelaprctica'></a>Entrega de la práctica a traves de PRADO y GitHub. Documentación de la práctica

Para que la práctica sea evaluable debe ser entregada dentro del plazo requerido indicado en PRADO (link). Todas las prácticas que estén fuera de plazo no serán evaluadas y no podrán defenderse. 

La entrega se hará **a través PRADO** en el periodo de entrega y también **a través de GitHub** justo después del periodo de entegra (esta parte será para la realización de la DEFENSA de la práctica).

La documentación de la entrega debe contener:
- 1 fichero en formato `markdown` llamado README.md que contenga la documentación de la practica que incluya los siguientes apartados:
  - Nombre del alumno y grupo de prácticas
  - Perfil de GitHub asociado
  - Descripción de la práctica y problema a resolver
  - Servicios desplegados y su configuración (Aquí explica el método para desplegar que has usado y como lo has hecho incluyendo todos los detalles necesarios)
  - Conclusiones
  - Referencias bibliográficas y recursos utilizados

- Será necesario incluir todos los ficheros necesarios para el despliegue de los servicios que has creado.
- Material auxiliar (imágenes para la documentación, ficheros de configuración, etc.)

**Para la entrega en PRADO**, haz un fichero `.ZIP` con todo el contenido anterior y súbelo a la plataforma antes del plazo máximo.

**Para la entrega desde GitHub** (justo después de que pase el periodo de entrega por PRADO), será simplemente haciendo un `Fork` del repositorio de la asignatura en GitHub (https://github.com/manuparra/cc2122/) y luego incluyendo un directorio con tu nombre dentro de la carpeta `evaluation-practice-1`, y ahí incluir la documentación en formato `Markdown`, junto con los ficheros necesarios para el despliegue completo de los servicios.

La estructura para GitHub debe se la siguiente:

```
evaluation-practice-1/
           manuelparra/
                       README.md
                       docker-compose.yml
                       media/
                             screenshot1.png
                             ...
            alumnoXX/
                       README.md
                       docker-compose.yml
                       media/
                             screenshot1.png
                             ...
            ... 
```

Hecho esto, crea un `Pull Request` al repositorio de la asignatura para poder incluir tu práctica en el repositorio principal.

###  3.1. <a name='Plazosdeentrega'></a>Plazos de entrega

- Plazo de entrega en **PRADO**: del 21 de Marzo de 2022 a 17 de Abril de 2022.
- Plazo de entrega en **GitHub**: del 18 de Abril al 20 de Abril de 2022. 

###  3.2. <a name='Defensadelaprctica'></a>Defensa de la práctica

Será inmediatamente después de la entrega en GitHub en horario de clase de prácticas.

##  4. <a name='Criteriosdeevaluacin'></a>Criterios de evaluación

- El conjunto de servicios debe fucionar correctamente y levantarse sin problemas
  - Los 4 servicios deben funcionar y estar configurados
- Al menos deben existir 2 instancias de uno de los servicios (o bien Grafana o Prometheus server, o ambos).
- Configurar Prometheus con los elementos descritos en la práctica.
- Debes proveer de algún `script` para automatizar el despligue, ya sea con `docker-compose.yml`, un script en `bash`, o cualquier otro método que lo ponga todo el marcha.
- Incluir en la documentación como se lanza la provisión de servicios.

##  5. <a name='Criteriosdeevaluacinopcionales'></a>Criterios de evaluación opcionales

- Configuración en Kubernetes (con MiniKube) o sobre Helm.
- Proveer de alta disponibilidad tanto en `Prometheus-server` como en `Grafana`. Esto requerirá al menos dos servicios de `HAProxy` para cubrir los servicios.


  



