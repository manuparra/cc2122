# Cloud Computing: Servicios y Aplicaciones. Práctica 1

En este documento se encuentra la presentacion del trabajo realizado para la primera práctica de la asignatura, así como datos sobre el alumno, el problema a resolver, la configuración etc..

### Datos del Alumno

**Nombre del alumno**: Abel José Sánchez Alba

**Grupo de prácticas**: no asignado, el alumno se encuentra habitando en el extranjero, por lo que no va a clase de forma presencial.

[**Perfil de github**](https://github.com/ajalba)

## Descripción de la práctica y el problema a resolver

Esta práctica se centra en el despliegue de un servicio de monitorización basado en las herramientas _Prometheus-server_, _Prometheus node exporter_, _Grafana_ y _HAProxy_. Dicho servicio de monitorización debe interconectar dichos softwares para proporcionar métricas mediante la visualización de _Grafana_, el "scrape" de _Prometheus_ y el balance de carga de _HAProxy_.

En la práctica, los softwares deben estar dentro de contenedores Docker, la comunicación entre los contenedores debe dar forma al servicio. Para dar _alta fiabilidad_ al servicio, se ha decidido que se tendrán dos contenedores de _Grafana_, cuya carga estará balanceada con _HAProxy_.

En cuanto a la creación y despliegue de los contenedores, se ha realizado en dos modalidades; **Docker compose** y una modalidad que se ha llamado **Docker Simple**, es decir, la creación de cada una de las imagenes docker mediante dockerfiles y puesta en marcha mediante un script, lo que se podría considerar de un "más bajo nivel". Los detalles sobre cada implementación se encuentran dentro de sus respectivas secciones.

En cuanto a configuración de los servicios, es la misma en ambas modalidades, simplemente cambia la implementación y la forma de realizar la misma. La configuración se detallará en la sección de **Docker Simple**, pues en esta modalidad los detalles de configuración respecto a docker se indican de una forma más explícita y de bajo nivel, y personalmente creo que la descripción encaja mejor en esa sección, remarcando que la configuración de los servicios es la misma en las dos modalidades, solo cambia su implementación y herramientas utilizadas.

## Docker Simple

Los ficheros que componen el servicio en esta modalidad se encuentran dentro de la carpeta [SimpleDocker](./SimpleDocker/). Se tienen pues 5 carpetas, y en cada una de ellas se encuentra un fichero Dockerfile que formará la imagen de dicho software, se han nombrado las carpetas con el nombre del software del que contienen la información, para que la misma sea fácil de encontrar. Se crea una red para resolver los nombres de cada uno de los contenedores, y los contenedores asignarán un usuario sin privilegios de root, como normalmente se indica en las buenas prácticas. Todas las imágenes y contenedores creados en esta modalidad tienen el sufijo **-script** para indicar que han sido creadas con el script de despliegue _service.sh_ proporcionado. Comenzamos detallando las imágenes y configuración de cada software.

#### Grafana

El Dockerfile de _Grafana_ simplemente descarga una imagen del mismo y expone su puerto 3000. Tanto grafana como grafana-second expondrán sus puertos 3000 pero ninguno de ellos será enlazado a un puerto de la máquina host. En el momento de la construcción de los contenedores, se enlazan las subcarpetas **data** para el almacenamiento de datos de Grafana y **provisioning**, que aprovisiona datos para tener una data source y dashboard al que llegar por defecto, la documentación de estos detalles técnicos sobre aprovisionar grafana se encuentran [aquí](https://grafana.com/docs/grafana/latest/administration/provisioning/). Por lo que se ha seguido esta guía, para incluir un archivo que indique donde se encuentran los dashboards y un archivo json para un dashboard por defecto, así como otro archivo de data source por defecto en su subcarpeta.

``` Dockerfile
FROM grafana/grafana-oss
EXPOSE 3000
```

#### Prometheus Server

Para la configuración de prometheus server se ha creado un archivo _prometheus.yml_ cuyo contenido se basa en la configuración vista en clase, se tiene pues los targets de prometheus y prometheus node exporter, ambos en los puertos 9090 y 9100 respectivamente. En el momento de creación de la imagen de docker, es decir el dockerfile, se enlazan los archivos para la configuración y la base de datos, así como instaurar el usuario 1000, para no ejecutar contenedores en root. Se tiene un volumen de docker para almacenar los datos de prometheus server y se ha expuesto en el puerto 9090.

``` Dockerfile
FROM prom/prometheus:v2.30.3
ADD /Prometheus/prometheus.yml /etc/prometheus
ADD /Prometheus/data /etc/prometheus/data
EXPOSE 9090
USER 1000:1000
```

#### Node Exporter

En canto a node exporter, simplemente se ha tomado su imagen oficial y se ha expuesto su puerto 9100.

``` Dockerfile
FROM prom/node-exporter
EXPOSE 9100/tcp
```

#### HAProxy

Se ha configurado HAProxy para redirigir las peticiones enviadas al puerto 80 a los puertos de los contenedores de Grafana, se ha configurado para guardar cookies y que así, cuando un servidor es conectado con un cliente, esta conexión se repita con el mismo servidor cada vez que el cliente mande una petición. Si no se hiciera así, sería imposible mantener el login necesario en Grafana y ello interrumpiria el flujo de trabajo y la interacción con el servicio. Por otro lado, se ha asignado el puerto 8404 a las estadísticas de haproxy para comprobar que se realizan conexiones con ambos nodos Grafana.

La imagen de HAProxy crea un usuario y otorga permisos a su carpeta /var/run, carpeta esencial en la configuración.

``` Dockerfile
FROM haproxy
ADD haproxy.cfg /usr/local/etc/haproxy
USER root
RUN chown haproxy:haproxy /var/run
USER haproxy:haproxy
```

#### Script de Despliegue

Se ha proporcionado un script bash que ayuda al ddespliegue del servicio. Este script acepta 4 ordenes:

- **build**: Crea las imágenes de cada uno de los softwares, compuesta de los siguientes comandos

``` bash
docker build -t prometheus-server-script ./Prometheus
docker build -t prometheus-node-exporter-script ./NodeExporter
docker build -t grafana-script ./Grafana
docker build -t grafana-second-script ./Grafana-second
docker build -t haproxy-script ./HAProxy
```

- **unbuild**: elimina las imágenes creadas

- **start**: una vez creadas las imágenes, crea y ejecuta los contenedores que conforman el servicio. Tras ejecutar **./service.sh start** basta acceder a (http://localhost:80) para acceder a grafana y hacer uso de su visualización, o a (http://localhost:8404) para ver las estadísticas de HAProxy. La opción ejecuta los siguientes comandos:

```bash
docker network rm net-CCSA
docker network create net-CCSA  
docker run -t -i -d -p 9090:9090 --name prometheus-script --network net-CCSA -v storage-data:/etc/prometheus/data prometheus-server-script --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/etc/prometheus/data" --storage.tsdb.retention.time=7d
docker run -t -i -d -p 9100:9100 --name node-exporter-script --network net-CCSA prometheus-node-exporter-script
docker run -t -i -d --name grafana-script --network net-CCSA --user 1000 -v "$PWD/Grafana/data:/var/lib/grafana" -v "$PWD/Grafana/provisioning:/etc/grafana/provisioning" grafana-script
docker run -t -i -d --name grafana-second-script --network net-CCSA --user 1000 -v "$PWD/Grafana-second/data:/var/lib/grafana" -v "$PWD/Grafana-second/provisioning:/etc/grafana/provisioning" grafana-second-script
docker run -t -i -d -p 80:80 -p 8404:8404 --name haproxy-script --network net-CCSA haproxy-script
```

Se crea la red para resolver los nombres de los contenedores y se enlazan los puertos de los contenedores que se expondrán al exterior con los puertos de la máquina host.

- **clean**: detiene y elimina los contenedores creados con start, por lo que se puede utilizar el mismo script para iniciar el servicio y posteriormente deja la máquina "limpia".

## Docker Compose

En este modo de despliegue, las imagenes construidas anteriormente se sustituyen por su equivalente en docker compose, no es necesario crear una red de docker, pues se emplea la red por defecto para resolver nombres. Para el usuario y grupo, se tiene un archivo .env, donde se tiene una variable UID y GID, para IDs de grupo y usuario, en este caso ambos son 1000. Además, los volúmenes se especifican en la correspondiente sección del fichero, así como los puertos, o nombres de los contenedores, se toman las mismas imágenes, pero los detalles de configuración vienen en el propio fichero docker-compose.

En general, la configuración se compone de:

- **Network**: network por defecto.
- **Usuario**: usuario 1000 introducido en la variable UID del fichero **.env**.
- **Grupo**: grupo 1000 introducido en la variable GID del fichero **.env**.
- **Volumen**: volumen creado para la base de datos de prometheus, llamado **storage_data**.
- **Puertos**: especificados en su sección del servicio.

La configuración de servicios es la misma que en la sección **Docker Simple**. En cuanto a uso, simplemente interactuar con docker compose mediante **docker compose up/down**.

Cabe destacar que los detalles como los nombres del contenedor, los comandos a ejecutar o los puertos expuestos o enlazados con el sistema host, se indican de forma mucho mas clara y sencilla en la modalidad docker compose, que proporciona una capa de abstracción necesaria y que ayuda mucho en cuanto a lo que a la coordinación de contenedores se refiere.

## Conclusiones

La implementación de un servicio de monitorización que haga uso de varios contenedores con diferentes imágenes es un problema que permite introducirse y profundizar en la coordinación de contenedores. Su implementación en lo que se ha llamado en este documento **Docker Simple** permite conocer un amplio número de detalles y aspectos sobre como se crean, comunican y administran los contenedores de docker, por lo que enseña a bajo nivel qué ocurre cuando se implementa el mismo servicio con docker compose. A su vez, la implementación de este servicio hace uso de varios conceptos y técnicas que se encuentran entre el desarrollo de software "puro" y la parte técnica de redes, lo cual supone un reto pero a su vez ayuda a ampliar el concepto de desarrollo de software y las habilidades necesarias para el mismo.

#### Bibliografía

[provisioning grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/)

[configuración haproxy](https://www.haproxy.com/blog/the-four-essential-sections-of-an-haproxy-configuration/)

[docker volumes](https://docs.docker.com/storage/volumes/)

[docker networks](https://docs.docker.com/network/)