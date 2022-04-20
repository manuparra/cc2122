#!/bin/bash
PROM_COMMANDS="--web.enable-lifecycle --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/etc/prometheus/console_libraries --web.console.templates=/etc/prometheus/consoles --storage.tsdb.retention.time=7d"
EXPORTER_COMMANDS="--path.procfs=/host/proc --path.rootfs=/rootfs --path.sysfs=/host/sys"

echo "MODALIDAD CONTENEDORES SIN ORQUESTADOR"

if [ $1 == "stop" ];
then
    echo "PARANDO CONTENEDORES"
    docker stop node-prom
    docker stop practica1-exporter-1
    docker stop practica1-exporter-2
    docker stop practica1-grafana-1
    docker stop practica1-grafana-2
    docker stop node-haproxy
    docker rm node-prom
    docker rm practica1-exporter-1
    docker rm practica1-exporter-2
    docker rm practica1-grafana-1
    docker rm practica1-grafana-2
    docker rm node-haproxy
elif [ $1 == "run" ]; 
then
    echo "CREANDO VOLUMENES"
    docker volume create prometheus-data
    docker volume create grafana-data

    echo "CREANDO RED DE CONTENEDORES"
    docker network create cc_p1_network

    echo "EJECUTANDO CONTENEDORES"
    docker run -it -d --name node-prom -v $(pwd)/prometheus:/etc/prometheus -v prometheus-data:/prometheus -p 9090:9090 --network cc_p1_network prom/prometheus:latest $PROM_COMMANDS
    docker run -it -d --name practica1-exporter-1 -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro --expose 9100 --network cc_p1_network prom/node-exporter $EXPORTER_COMMANDS
    docker run -it -d --name practica1-exporter-2 -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro --expose 9100 --network cc_p1_network prom/node-exporter $EXPORTER_COMMANDS
    docker run -it -d --name practica1-grafana-1 -v $(pwd)/grafana/provisioning/:/etc/grafana/provisioning/ -v grafana-data:/var/lib/grafana --expose 3000 --network cc_p1_network grafana/grafana-oss
    docker run -it -d --name practica1-grafana-2 -v $(pwd)/grafana/provisioning/:/etc/grafana/provisioning/ -v grafana-data:/var/lib/grafana --expose 3000 --network cc_p1_network grafana/grafana-oss
    docker run -it -d --name node-haproxy -v $(pwd)/haproxy:/haproxy-override -v $(pwd)/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro -p 8080:80 --network cc_p1_network haproxy:1.6
fi
