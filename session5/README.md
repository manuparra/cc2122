<!-- vscode-markdown-toc -->
* 1. [Dockerfile](#Dockerfile)
* 2. [Docker-Compose](#Docker-Compose)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

# Session 5: Tutorial on Dockerfiles and docker-compose + Practice presentation

##  1. <a name='Dockerfile'></a>Dockerfile

It is a simple text file with a set of command or instruction. These commands/instructions are executed successively to perform actions on the base image to create a new docker image.

Dockerfile syntax

```
#Line blocks used for commenting

command argument argument1 ... 
```

Below is how your workflow will look like:

:one: Create a Dockerfile and mention the instructions to create your docker image
:two: Run docker build command which will build a docker image
:three: Now the docker image is ready to be used, use docker run command to create containers


![](https://geekflare.com/wp-content/uploads/2019/07/dockerfile.png)

Commands to use for the Dockerfile:

- `FROM` – Defines the base image to use and start the build process.

- `RUN` – It takes the command and its arguments to run it from the image.

- `CMD` – Similar function as a RUN command, but it gets executed only after the container is instantiated.

- `ENTRYPOINT` – It targets your default application in the image when the container is created.

- `ADD` – It copies the files from source to destination (inside the container).

- `ENV` – Sets environment variables.

Firstly, let’s create a Dockerfile:

```
    FROM centos:7
    MAINTAINER manuelparra

    LABEL Remarks="This is a dockerfile example for CentOS system"

    RUN yum -y update && yum -y install httpd && \
            yum clean all

    
    EXPOSE 80

    WORKDIR /root

```

This is just a Dockerfile to create a container with a simple HTTPD service (Apache).

To build it:

```
docker build . -t myfirstcontainer
```

Now we are going to create a more complex application from a Dockerfile that serves a nodejs application.

Our Dockerfile will be the next:

```
FROM debian
# Copy application files
COPY . /app
# Install required system packages
RUN apt-get update
RUN apt-get -y install imagemagick curl software-properties-common gnupg vim ssh
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -y install nodejs
# Install NPM dependencies
RUN npm install --prefix /app
EXPOSE 80
CMD ["npm", "start", "--prefix", "app"]

```

Clone this [repository](https://github.com/juan131/dockerfile-best-practices) to have all the files that are used in the sentence COPY.

Then run:

```
docker build . -t nodeapp
```

Once this command is executed, you will have the image stored in Docker ready to launch the container:

```
# See docker images
docker images
```

And now run the container with this image:

```
docker run -d -p 80:80 nodeapp
```

##  2. <a name='Docker-Compose'></a>Docker-Compose

Now for the advanced stuff. Docker Compose is a Docker tool used to define and run multi-container applications. With Compose, you use a YAML file to configure your application’s services and create all the app’s services from that configuration.

Think of docker-compose as an automated multi-container workflow. Compose is an excellent tool for development, testing, CI workflows, and staging environments. According to the Docker documentation, the most popular features of Docker Compose are:

- Multiple isolated environments on a single host
- Preserve volume data when containers are created
- Only recreate containers that have changed
- Variables and moving a composition between environments
- Orchestrate multiple containers that work together

Now that we know how to download Docker Compose, we need to understand how Compose files work. It’s actually simpler than it seems. In short, Docker Compose files work by applying mutiple commands that are declared within a single docker-compose.yml configuration file.

The basic structure of a Docker Compose YAML file looks like this:

```
version: 'X'

services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
  redis:
    image: redis
```

Now, let’s look at real-world example of a Docker Compose file and break it down step-by-step to understand all of this better. Note that all the clauses and keywords in this example are commonly used keywords and industry standard.


With just these, you can start a development workflow. There are some more advanced keywords that you can use in production, but for now, let’s just get started with the necessary clauses.

```
version: '3'
services:
  web:
    # Path to dockerfile.
    # '.' represents the current directory in which
    # docker-compose.yml is present.
    build: .

    # Mapping of container port to host
    
    ports:
      - "5000:5000"
    # Mount volume 
    volumes:
      - "/usercode/:/code"

    # Link database container to app container 
    # for reachability.
    links:
      - "database:backenddb"
    
  database:

    # image to fetch from docker hub
    image: mysql/mysql-server:5.7

    # Environment variables for startup script
    # container will use these variables
    # to start the container with these define variables. 
    environment:
      - "MYSQL_ROOT_PASSWORD=root"
      - "MYSQL_USER=testuser"
      - "MYSQL_PASSWORD=admin123"
      - "MYSQL_DATABASE=backend"
    # Mount init.sql file to automatically run 
    # and create tables for us.
    # everything in docker-entrypoint-initdb.d folder
    # is executed as soon as container is up nd running.
    volumes:
      - "/usercode/db/init.sql:/docker-entrypoint-initdb.d/init.sql"
    
```


- `version ‘3’`: This denotes that we are using version 3 of Docker Compose, and Docker will provide the appropriate features. At the time of writing this article, version 3.7 is latest version of Compose.
- `services`: This section defines all the different containers we will create. In our example, we have two services, web and database.
- `web`: This is the name of our Flask app service. Docker Compose will create containers with the name we provide.
- `build`: This specifies the location of our Dockerfile, and . represents the directory where the docker-compose.yml file is located.
- `ports`: This is used to map the container’s ports to the host machine.
- `volumes`: This is just like the -v option for mounting disks in Docker. In this example, we attach our code files directory to the containers’ `./code` directory. This way, we won’t have to rebuild the images if changes are made.
- `links`: This will link one service to another. For the bridge network, we must specify which container should be accessible to which container using links.
- `image`: If we don’t have a Dockerfile and want to run a service using a pre-built image, we specify the image location using the image clause. Compose will fork a container from that image.
- `environment`: The clause allows us to set up an environment variable in the container. This is the same as the -e argument in Docker when running a container.

To deploy the services:

```
docker-compose up -d
```

To un-deploy the services:

```
docker-compose down
```

Docker Compose commands

Now that we know how to create a docker-compose file, let’s go over the most common Docker Compose commands that we can use with our files. Keep in mind that we will only be discussing the most frequently-used commands.

`docker-compose`: Every Compose command starts with this command. You can also use docker-compose <command> --help to provide additional information about arguments and implementation details.


```
$ docker-compose --help
Define and run multi-container applications with Docker.
```


`docker-compose build`: This command builds images in the docker-compose.yml file. The job of the build command is to get the images ready to create containers, so if a service is using the prebuilt image, it will skip this service.

```
$ docker-compose build
database uses an image, skipping
Building web
Step 1/11 : FROM python:3.9-rc-buster
 ---> 2e0edf7d3a8a
Step 2/11 : RUN apt-get update && apt-get install -y docker.io
```

`docker-compose images`: This command will list the images you’ve built using the current docker-compose file.

```
$ docker-compose images
          Container                  Repository        Tag       Image Id       Size  
--------------------------------------------------------------------------------------
7001788f31a9_docker_database_1   mysql/mysql-server   5.7      2a6c84ecfcb2   333.9 MB
docker_database_1                mysql/mysql-server   5.7      2a6c84ecfcb2   333.9 MB
docker_web_1                     <none>               <none>   d986d824dae4   953 MB
```

`docker-compose stop`: This command stops the running containers of specified services.

```
$ docker-compose stop
Stopping docker_web_1      ... done
Stopping docker_database_1 ... done
```

`docker-compose run`: This is similar to the docker run command. It will create containers from images built for the services mentioned in the compose file.

```
$ docker-compose run web
Starting 7001788f31a9_docker_database_1 ... done
 * Serving Flask app "app.py" (lazy loading)
 * Environment: development
 * Debug mode: on
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 116-917-688
```

`docker-compose up`: This command does the work of the docker-compose build and docker-compose run commands. It builds the images if they are not located locally and starts the containers. If images are already built, it will fork the container directly.

```
$ docker-compose up
Creating docker_database_1 ... done
Creating docker_web_1      ... done
Attaching to docker_database_1, docker_web_1
```

`docker-compose ps`: This command list all the containers in the current docker-compose file. They can then either be running or stopped.

```
$ docker-compose ps
      Name                 Command             State               Ports         
---------------------------------------------------------------------------------
docker_database_1   /entrypoint.sh mysqld   Up (healthy)   3306/tcp, 33060/tcp   
docker_web_1        flask run               Up             0.0.0.0:5000->5000/tcp
 
$ docker-compose ps
      Name                 Command          State    Ports
----------------------------------------------------------
docker_database_1   /entrypoint.sh mysqld   Exit 0        
docker_web_1        flask run               Exit 0    
```

`docker-compose down`: This command is similar to the docker system prune command. However, in Compose, it stops all the services and cleans up the containers, networks, and images.

```
$ docker-compose down
Removing docker_web_1      ... done
Removing docker_database_1 ... done
Removing network docker_default
(django-tuts) Venkateshs-MacBook-Air:Docker venkateshachintalwar$ docker-compose images
Container   Repository   Tag   Image Id   Size
----------------------------------------------
(django-tuts) Venkateshs-MacBook-Air:Docker venkateshachintalwar$ docker-compose ps
Name   Command   State   Ports
------------------------------
```


And here examples related to the practice 1.

```
version: '3'

services:
  prometheus:
    container_name: node-prom
    image: prom/prometheus:latest
    ports:
      - 9090:9090
    depends_on:
      - apache
      - grafana
  apache:
    container_name: apache
    image: httpd
    ports:
      - 8080:80
  grafana:
    image: grafana/grafana-oss
    ports:
      - 3000:3000

```



