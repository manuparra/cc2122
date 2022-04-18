#!/bin/bash
if [ "$1" == "build" ];
then
echo "-------------------------- Building prometheus server image --------------------------"
docker build -t prometheus-server-script ./Prometheus
echo "-------------------------- Building prometheus node exporter image --------------------------"
docker build -t prometheus-node-exporter-script ./NodeExporter
echo "-------------------------- Building grafana, first node image --------------------------"
docker build -t grafana-script ./Grafana
echo "-------------------------- Building grafana, second node image --------------------------"
docker build -t grafana-second-script ./Grafana-second
echo "-------------------------- Building HAproxy image --------------------------"
docker build -t haproxy-script ./HAProxy
else if [ "$1" == "unbuild" ];
    then
    echo "-------------------------- Removing prometheus server image --------------------------"
    docker rmi prometheus-server-script
    echo "-------------------------- Removing prometheus node exporter image --------------------------"
    docker rmi prometheus-node-exporter-script
    echo "-------------------------- Removing grafana, first node image --------------------------"
    docker rmi grafana-script
    echo "-------------------------- Removing grafana, second node image --------------------------"
    docker rmi grafana-second-script
    echo "-------------------------- Removing HAproxy image --------------------------"
    docker rmi haproxy-script
    else if [ "$1" == "start" ];
        then
        docker network rm net-CCSA
        docker network create net-CCSA  
        echo "-------------------------- Building prometheus server container --------------------------"
        docker run -t -i -d -p 9090:9090 --name prometheus-script --network net-CCSA -v storage-data:/etc/prometheus/data prometheus-server-script --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/etc/prometheus/data" --storage.tsdb.retention.time=7d
        echo "-------------------------- Building prometheus node exporter container --------------------------"
        docker run -t -i -d -p 9100:9100 --name node-exporter-script --network net-CCSA prometheus-node-exporter-script
        echo "-------------------------- Building grafana, first node container --------------------------"
        docker run -t -i -d --name grafana-script --network net-CCSA --user 1000 -v "$PWD/Grafana/data:/var/lib/grafana" -v "$PWD/Grafana/provisioning:/etc/grafana/provisioning" grafana-script
        echo "-------------------------- Building grafana, second node container --------------------------"
        docker run -t -i -d --name grafana-second-script --network net-CCSA --user 1000 -v "$PWD/Grafana-second/data:/var/lib/grafana" -v "$PWD/Grafana-second/provisioning:/etc/grafana/provisioning" grafana-second-script
        echo "-------------------------- Building HAproxy container --------------------------"
        docker run -t -i -d -p 80:80 -p 8404:8404 --name haproxy-script --network net-CCSA haproxy-script
        else if [ "$1" == "clean" ];
            then
            docker network create net-CCSA  
            echo "-------------------------- removing prometheus server container --------------------------"
            docker stop prometheus-script
            docker rm prometheus-script
            echo "-------------------------- removing prometheus node exporter container --------------------------"
            docker stop node-exporter-script
            docker rm node-exporter-script
            echo "-------------------------- removing grafana, first node container --------------------------"
            docker stop grafana-script
            docker rm grafana-script
            echo "-------------------------- removing grafana, second node container --------------------------"
            docker stop grafana-second-script
            docker rm grafana-second-script
            echo "-------------------------- removing HAproxy container --------------------------"
            docker stop haproxy-script
            docker rm haproxy-script
            fi
        fi
    fi
fi 
