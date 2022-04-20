# Uso de docker-compose

## Ejecución

#### > docker-compose up -d 
Levanta la infraestructura diseñada en el fichero docker-compose.yml

```
Creating network "compose_backend" with driver "bridge"
Creating network "compose_frontend" with driver "bridge"
Creating volume "compose_prometheus_data" with default driver
Creating volume "compose_grafana_data" with default driver
Creating prometheus      ... done
Creating sqlite3         ... done
Creating node-exporter_2 ... done
Creating node-exporter_1 ... done
Creating haproxy         ... done
Creating grafana_1       ... done
Creating grafana_2       ... done
Creating haproxy_front   ... done
```

Si ejecutamos la misma operación una vez levantada la infraestructura nos dirá que todas las máquinas están a la última versión disponible, es decir, busca si existe alguna modificación en el fichero de docker-compose.yml y la actualiza en caso de ser necesario.

#### > docker-compose up -down 
Destruccción de la infraestructura creada anteriormente

```
Stopping haproxy_front   ... done
Stopping grafana_1       ... done
Stopping grafana_2       ... done
Stopping haproxy         ... done
Stopping sqlite3         ... done
Stopping node-exporter_1 ... done
Stopping prometheus      ... done
Stopping node-exporter_2 ... done
Removing haproxy_front   ... done
Removing grafana_1       ... done
Removing grafana_2       ... done
Removing haproxy         ... done
Removing sqlite3         ... done
Removing node-exporter_1 ... done
Removing prometheus      ... done
Removing node-exporter_2 ... done
Removing network compose_backend
Removing network compose_frontend
```

## Infraestructura

![Representacion de la infraestructura](imgs/infra.png "Diseño infraestructura")

![Docker](imgs/compose.png "Representacion en Docker")

