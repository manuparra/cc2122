#!/bin/bash

if [ $1 = "clone" ] ; then
    echo "CLONING REPOSITORY..."
    git clone https://github.com/migueg/CC2-2122-MasterUGR.git
    cd "./CC2-2122-MasterUGR/P1"
fi;
if [ $1 = "container" ] ; then

    if [ $2 = "start" ] ; then

        echo "CRETING NETWORK BRIDGE..."
        docker network create --driver=bridge mynetwork
        echo "--------------------------------"
        echo "BUILDING IMAGES..."
        echo "--------------------------------"
        docker build -t prometheus-image ./Docker/PrometheusServer
        echo "--------------------------------"
        echo "CREATING AND RUNNING CONTAINERS..."
        echo "--------------------------------"

        echo "Starting Prometheus server container..."
        docker run -d -p 9090:9090 --name my-prometheus --net mynetwork -v prometheus_data:/prometheus prometheus-image \
        --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/etc/prometheus/console_libraries \
        --web.console.templates=/etc/prometheus/consoles --web.enable-lifecycle --storage.tsdb.retention.time=7d
        echo "Prometheus server should be running on localhost:9090 if no errors"

        echo "Starting Prometheus node exporter A container..."
        docker run -d -p 9100:9100 --name node-exporterA --net mynetwork\
        -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro  \
        quay.io/prometheus/node-exporter:latest \
        --path.rootfs=/host  --path.procfs=/host/proc --path.sysfs=/host/sys
        echo "Prometheus node exporter A should be running on localhost:9100 if no errors"
        echo "--------------------------------"

        echo "Starting Prometheus node exporter B container..."
        docker run -d -p 9110:9100 --name node-exporterB --net mynetwork\
        -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro  \
        quay.io/prometheus/node-exporter:latest \
        --path.rootfs=/host  --path.procfs=/host/proc --path.sysfs=/host/sys
        echo "Prometheus node exporter B should be running on localhost:9110 if no errors"
        echo "--------------------------------"

        echo "Starting Grafana A container..."
        docker run  -d -p 3000:3000 \
        --name grafanaA \
        --user 104 \
        --net mynetwork \
        -v $(pwd)/Docker/Grafana/provisioning/datasource:/etc/grafana/provisioning/datasources \
        -v $(pwd)/Docker/Grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards \
        -v grafana_data:/var/lib/grafana grafana/grafana-enterprise:8.2.0
        echo "Grafana A should be running on localhost:3000 if no errors"
        echo "--------------------------------"

        echo "Starting Grafana B container..."
        docker run -d -p  3030:3000 \
        --name grafanaB \
        --user 104 \
        --net mynetwork \
        -v $(pwd)/Docker/Grafana/provisioning/datasource:/etc/grafana/provisioning/datasources \
        -v $(pwd)/Docker/Grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards \
        -v grafana_data:/var/lib/grafana grafana/grafana-enterprise:8.2.0
        echo "Grafana B should be running on localhost:3030 if no errors"
        echo "--------------------------------"

        echo "Starting HA proxy container..."
        docker run  -d \
        --name haproxy \
        --net mynetwork \
        -v $(pwd)/Docker/HAProxy:/usr/local/etc/haproxy:ro \
        -p 8000:80 \
        -p 8404:8404 \
        haproxy:latest
        echo "Ha proxy should be running on localhost:8040 if no errors"
        echo "--------------------------------"
    fi

    if [ $2 = "up" ] ; then

    echo "STARTING CONTAINERS..."
    echo "--------------------------------"
    docker container start my-prometheus
    docker container start node-exporterA
    docker container start node-exporterB
    docker container start grafanaA
    docker container start grafanaB
    docker container start haproxy
    echo "--------------------------------"
    fi

    if [ $2 = "down" ] ; then

    echo "STOPPING CONTAINERS..."
    echo "--------------------------------"
    docker container stop my-prometheus
    docker container stop node-exporterA
    docker container stop node-exporterB
    docker container stop grafanaA
    docker container stop grafanaB
    docker container stop haproxy
    echo "--------------------------------"
    fi

    if [ $2 = "delete" ]; then
        echo "REMOVING CONTAINERS AND IMAGES..."
        echo "--------------------------------"
        docker container stop my-prometheus
        docker container rm my-prometheus
        docker image rm prometheus-image
        docker container stop node-exporterA
        docker container stop node-exporterB
        docker container rm node-exporterA
        docker container rm node-exporterB
        docker image rm quay.io/prometheus/node-exporter:latest
        docker container stop grafanaA
        docker container stop grafanaB
        docker container rm grafanaA
        docker container rm grafanaB
        docker image rm grafana/grafana-enterprise:8.2.0
        docker container stop haproxy
        docker container rm haproxy
        docker image rm haproxy
        echo "--------------------------------"
    fi

fi

if [ $1 = "compose" ] ; then
    if [ $2 = "up" ] ; then
        docker-compose up
    fi
    if [ $2 = "down" ] ; then
        docker-compose down
    fi
fi
