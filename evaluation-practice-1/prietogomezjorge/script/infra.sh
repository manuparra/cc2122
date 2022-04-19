## Replica del funcionamiento de docker-compose

ayuda='Las directivas que puedes usar son:
           - up | UP | Up : levantar la infraestructura
           - down | DOWN | Down : apagar la infraestructura'

contenedores="prometheus haproxy node-exporter_1 node-exporter_2 grafana"

case $1 in

  up | UP | Up)
    printf "Levantando infraestructura...\n"
    
    printf "Creacion de los volumenes: \n"
    printf "Creacion del volumen "
    docker volume create prometheus_data

    printf "\nCreacion de las redes: \n"
    printf "backend: "
    docker network create --driver=bridge backend

    printf "\nCreacion de los servicios: \n"
    printf "prometheus: "
    docker run -d --name prometheus --restart=unless-stopped --mount type=bind,source=${PWD}/prometheus/config/prometheus.yml,target=/etc/prometheus/prometheus.yml --mount source=prometheus_data,target=/prometheus -p 9090:9090 --network=backend  prom/prometheus:latest --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=7d
    printf "haproxy: "
    docker run -d --name haproxy --mount type=bind,source=${PWD}/haproxy/haproxy.cfg,target=/usr/local/etc/haproxy/haproxy.cfg --network=backend -p 8080:80 -p 8404:8404 haproxy:latest    
    printf "node-exporter_1: "
    docker run -d --name node-exporter_1 --restart=unless-stopped --expose 9100 --network=backend prom/node-exporter:latest
    printf "node-exporter_2: "
    docker run -d --name node-exporter_2 --restart=unless-stopped --expose 9100 --network=backend prom/node-exporter:latest
    printf "grafana: "
    docker run -d --name grafana --restart=unless-stopped --mount type=bind,source=${PWD}/grafana/provisioning/dashboard/dashboard.yml,target=/etc/grafana/provisioning/dashboards/dashboard.yml --mount type=bind,source=${PWD}/grafana/provisioning/dashboard/node-exporter-full_rev26.json,target=/etc/grafana/provisioning/dashboards/node-exporter-full_rev26.json --mount type=bind,source=${PWD}/grafana/provisioning/datasources/datasource.yml,target=/etc/grafana/provisioning/datasources/datasource.yml --network=backend -p 3000:3000 grafana/grafana:latest

    printf "\n\nSistema desplegado en http://localhost:3000"
    ;;

  down | DOWN | Down)
    printf "Apagando infraestructura...\n"

    printf "\nApagado de los servicios: \n"
    for val in ${contenedores[*]}; do
      printf "Parando "
      docker stop $val
      sleep 3s
      printf "Eliminando "
      docker rm $val
    done
   
    printf "\nEliminacion de los volumenes: \n"
    docker volume rm prometheus_data
    docker volume rm grafana_data

    printf "\nEliminacion de las redes: \n"
    docker network rm frontend
    docker network rm backend
    ;;

  help | HELP | Help)
    echo "$ayuda"
    ;;

  *)
    echo -n "Usa la opcion help para saber mas"

esac
