# Práctica 1: Desarrollo y despliegue de servicios de monitorización en Cloud Computing usando contenedores

## Objetivos de la práctica

- Crear servicios interconectados usando contenedores.
- Conocer el despliegue de servicios en contenedores usando docker, docker-compose o kubernetes.
- Gestionar la escalabilidad de los servicios.
- Implementar una estrucutra de contenedores para que provea de alta disponibilidad.
- Soporte del servicio para múltiples usuarios al mismo tiempo.
- Utilización de servicios de monitorización en para Cloud Computing.

## Descripción del trabajo a desarrollar en la práctica

### Introducción

El despliegue de servicios en Cloud Computing es fundamental para poner en marcha funcionalidades que permitan tener aplicaciones y software además de infrastructuras con capacidades de soporte de múltiples usuarios y con posibilidades de escalado dinàmico. Aprovechar los recursos que ofrece Cloud Computing de forma fñexible es la clave para el correcto diseño de servicios y microservicios interconectados a través de contenedores y desplegados en la nube. 

Hoy en día cada vez existen más dispositivos conectados a Internet y transmitiendo datos de todo tipo a través de los servicios y recursos que provee CloudComputing. Desde IoT, hasta industra, pasando por nuestros hogares, todos ellos están interconectados. Existe una necesidad de monitorizar servicios, infrastructuras y recursos que nos permitan conocer el estado de estos elementos en tiempo real y poder decidir sobre lo que esta ocurriendo en términos de consumo, ocupación de CPU, RAM, o espacio de almacenamiento entre otros. Estos sistemas de monitorización son extremadamente flexibles y muy modulares, lo que los hace excelentes para su desarrollo y despliegue utilizando contenedores u otras herramientas de orquestación.

En este contexto, el objetivo principal de esta práctica es el despligue de un sistema de monitorización completo que proveea de los siguientes elementos:

- Servicio de captura de métricas
- Servicio de exportación/publicación de métricas en nodos a monitorizar.
- Servicio de visualización de métricas
- Servicio de alta disponibilidad para uno de los servicios anteriores.

### Descripción del trabajo de la práctica

Este trabajo consiste en proveer de un sistema de monitorización basado en Prometheus que permita capturar las métricas, insertarlas en su base de datos y publicarlas para poder visualizarlas a través de Grafana. Además de esto se requiere de un servicio que ofrezca alta disponibilidad para al menos uno de los servicios anteriores (por ejemplo Grafana o bien Prometheus).

Para esta práctica evaluable se desplegarán los siguientes servicios:

-  Para los *servicios de monitorización* y *exportación de métricas* se usanrán las herramientas y servicios proporcionados por el motor de monitorización  Prometheus (https://prometheus.io/). - Para el servicio de visualización de métricas se usará el Grafana (https://grafana.com/). 
- Para el servicio de alta disponibilidad se usará HAProxy u otro servicio similar (http://www.haproxy.org/).

Una breve descripción de los servicios individuales se detalla en las siguientes subsecciones.

#### Prometheus

Prometheus es un conjunto de herramientas de monitorización y alerta de sistemas de código abierto.

Prometheus recopila y almacena sus métricas como datos de series temporales, es decir, la información de las métricas se almacena con la marca de tiempo en la que se registró, junto con pares clave-valor opcionales llamados etiquetas que contienen los valores a monitorizar: CPU, RAM, etc.

Las principales características de Prometheus son

    - un modelo de datos multidimensional con datos de series temporales identificados por el nombre de la métrica y los pares clave/valor
  
    - no depende del almacenamiento distribuido; los nodos del servidor son autónomos


    - la recopilación de series temporales se realiza mediante un modelo de extracción a través de HTTP


    - los objetivos se descubren mediante el descubrimiento de servicios o la configuración estática


#### Grafana


Grafana es una solución de código abierto para ejecutar analíticas de datos, extraer métricas que den sentido a la cantidad masiva de datos y monitorizar nuestras aplicaciones con la ayuda de  cuadros de mando personalizables.

Grafana se conecta con todas las fuentes de datos posibles, comúnmente conocidas como bases de datos  como Graphite, Prometheus, Influx DB, ElasticSearch, MySQL, PostgreSQL, etc.

La herramienta nos ayuda a estudiar, analizar y supervisar los datos durante un período de tiempo, técnicamente llamado análisis de series de tiempo.

#### HAProxy

HAProxy es un proxy inverso de código abierto, muy rápido y fiable que ofrece alta disponibilidad, equilibrio de carga y proxy para aplicaciones basadas en TCP y HTTP. A lo largo de los años se ha convertido en el balanceador de carga de código abierto y se incluye en la mayoría de las distribuciones de Linux y últimamente se despliega por defecto en las plataformas en la nube.

### Implementación de los servicios con contenedores

La idea de esta práctica es que el alumno sea capaz de poner en marcha un sistema basado en contenedores  para la monitorización que tenga los 3 servicios (4 en total: 2 de Prometheus[ 1 para node-exporter, y 1 para prometheus server], 1 para Grafana y 1 para HAProxy) citados anteriormente.

Para esta implementación con contenedores, se puede elegir uno de los siguientes métodos de despliegue de servicios para Cloud Computing:

#### Docker

Para esta opción de despligue la práctica consistirá en desarrollar cada uno de los contenedores de forma individual para que alberguen cada uno de los servicios siguientes:

- Prometeus server
- Prometeus node-exporter
- Grafana community
- HAProxy

Esta opción implica que los contenedores tienen que ejecutarse sin un orquestador, lo que requerirá que se cree un script para poder desplegar y también bajar todos los servicios. 

#### docker-compose

Para esta opción se requiere el uso de la herramienta de composición de servicios `docker-compose` que provee Docker. Para ello debes tenerla instalada en tu sistema si ya previamente tienes Docker instalado.

Con esta opción al igual que la anterior se requiere que se incluyan todos los sevicios siguientes dentro del fichero de descripción de servicios a desplegar en `docker-compose`:

- Prometeus server
- Prometeus node-exporter
- Grafana community
- HAProxy

Dada la capacidad de `docker-compose` para automatizar el ciclo de vida de los servicios, solo será necesario crear el fichero `docker-compose.yml` que incluya todos los servicios descritos anteriormente.

#### Kubernetes

Este tipo de despliegue permite automatizar gran parte de las tareas y del ciclo de vida de los servicios, por lo que solo serán necesarios tener activos los servicios siguientes:

- Prometeus server
- Prometeus node-exporter
- Grafana community

El servicio de HAProxy puede se sustituido por el equivalente en kubernetes y que ofrece este tipo de servicio para poder balancear la carga entre los diferentes contenedores de cada `namespace`. 

También para esta forma de despliegue se puede utilizar Helm.

### Características de cada servicio para despliegue con contenedores 

Para cada uno de los servicios a desplegar se pide un minimo de configuración que provea de algunos rasgos de escalabilidad y configuración relacionados con Cloud Computing.

#### Servicio de `prometheus-server`

Se pide que el servicio de `prometheus-server` tenga:

- Al menos 2 contenedores o 2 replicas (si se usa `docker-compose` o `Kubernetes`).
- Las métricas deben ser almacenadas en un volumen compartido. Para ello debes utilizar la opción `volumes` en el fichero de `docker-compose`.
- Configurar el tiempo de retención de métricas a 1 semana. Para ello tendrás que utilizar la siguiente directiva: `--storage.tsdb.retention.time` para indicar el periodo.
- Usar la plantilla de configuración siguiente para el servicio de Prometheus. En este fichero puedes incluir la parametrización que se indica o bien desde
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


#### Servicio de `prometheus-node-exporter`

- Al menos 2 nodos o 2 contenedores a monitorizar diferentes.

#### Servicio de `grafana`

#### Servicio de `HAProxy`

