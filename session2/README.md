# Session 2: Intro to containers orchestrators

Although you can certainly manage research workflows that use multiple containers manually, there are a number of container orchestration tools that you may find useful when managing workflows that use multiple containers. We won’t go in depth on using these tools in this lesson but instead briefly describe a few options and point to useful resources on using these tools to allow you to explore them yourself.

- Docker Compose
- Kubernetes
- Docker Swarm


Use of container orchestration tools for research workflows is a relatively new concept and so there is not a huge amount of documentation and experience out there at the moment. You may need to search around for useful information or, better still, contact your friendly neighbourhood RSE to discuss what you want to do.

**Docker Compose Overview**


Docker Compose provides a way of constructing a unified workflow (or service) made up of multiple individual Docker containers. In addition to the individual Dockerfiles for each container, you provide a higher-level configuration file which describes the different containers and how they link together along with shared storage definitions between the containers. Once this high-level configuration has been defined, you can use single commands to start and stop the orchestrated set of containers.

**What is Kubernetes**

Kubernetes is an open source framework that provides similar functionality to Docker Compose. Its particular strengths are that is platform independent and can be used with many different container technologies and that it is widely available on cloud platforms so once you have implemented your workflow in Kubernetes it can be deployed in different locations as required. It has become the de facto standard for container orchestration.

**Docker Swarm Overview**

Docker Swarm provides a way to scale out to multiple copies of similar containers. This potentially allows you to parallelise and scale out your research workflow so that you can run multiple copies and increase throughput. This would allow you, for example, to take advantage of multiple cores on a local system or run your workflow in the cloud to access more resources. Docker Swarm uses the concept of a manager container and worker containers to implement this distribution.






# Session 2: Docker Compose

Make sure you have already installed both Docker Engine and Docker Compose. You don’t need to install Python or Redis, as both are provided by Docker images.

## Step 1: Setup

Define the application dependencies.

Create a directory for the project:

```
mkdir composetest
cd composetest
```

Create a file called app.py in your project directory and paste this in:
```
    import time

    import redis
    from flask import Flask

    app = Flask(__name__)
    cache = redis.Redis(host='redis', port=6379)

    def get_hit_count():
        retries = 5
        while True:
            try:
                return cache.incr('hits')
            except redis.exceptions.ConnectionError as exc:
                if retries == 0:
                    raise exc
                retries -= 1
                time.sleep(0.5)

    @app.route('/')
    def hello():
        count = get_hit_count()
        return 'Hello World! I have been seen {} times.\n'.format(count)
```

In this example, redis is the hostname of the redis container on the application’s network. We use the default port for Redis, 6379.

Handling transient errors

        Note the way the get_hit_count function is written. This basic retry loop lets us attempt our request multiple times if the redis service is not available. This is useful at startup while the application comes online, but also makes our application more resilient if the Redis service needs to be restarted anytime during the app’s lifetime. In a cluster, this also helps handling momentary connection drops between nodes.

Create another file called requirements.txt in your project directory and paste this in:


```
    flask
    redis
```

## Step 2: Create a Dockerfile

In this step, you write a Dockerfile that builds a Docker image. The image contains all the dependencies the Python application requires, including Python itself.

In your project directory, create a file named Dockerfile and paste the following:

```
# syntax=docker/dockerfile:1
FROM python:3.7-alpine
WORKDIR /code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask", "run"]
```

This tells Docker to:

    Build an image starting with the Python 3.7 image.
    Set the working directory to /code.
    Set environment variables used by the flask command.
    Install gcc and other dependencies
    Copy requirements.txt and install the Python dependencies.
    Add metadata to the image to describe that the container is listening on port 5000
    Copy the current directory . in the project to the workdir . in the image.
    Set the default command for the container to flask run.

For more information on how to write Dockerfiles, see the Docker user guide and the Dockerfile reference.


## Step 3: Define services in a Compose file

Create a file called `docker-compose.yml` in your project directory and paste the following:

```
version: "3.9"
services:
  web:
    build: .
    ports:
      - "8000:5000"
  redis:
    image: "redis:alpine"
```

This Compose file defines two services: web and redis.

*Web service*

The web service uses an image that’s built from the Dockerfile in the current directory. It then binds the container and the host machine to the exposed port, 8000. This example service uses the default port for the Flask web server, 5000.
Redis service

The redis service uses a public Redis image pulled from the Docker Hub registry.

## Step 4: Build and run your app with Compose

    From your project directory, start up your application by running docker-compose up.

 ```
 docker-compose up
 ```

Compose pulls a Redis image, builds an image for your code, and starts the services you defined. In this case, the code is statically copied into the image at build time.

Enter http://localhost:8000/ in a browser to see the application running.

If you’re using Docker natively on Linux, Docker Desktop for Mac, or Docker Desktop for Windows, then the web app should now be listening on port 8000 on your Docker daemon host. Point your web browser to http://localhost:8000 to find the Hello World message. If this doesn’t resolve, you can also try http://127.0.0.1:8000.

You should see a message in your browser saying:

``hello world in browser``

Refresh the page.

The number should increment.

```hello world in browser``

Switch to another terminal window, and type docker image ls to list local images.

Listing images at this point should return redis and web.

````
docker image ls
````

    You can inspect images with docker inspect <tag or id>.

    Stop the application, either by running docker-compose down from within your project directory in the second terminal, or by hitting CTRL+C in the original terminal where you started the app.

## Step 5: Edit the Compose file to add a bind mount

Edit docker-compose.yml in your project directory to add a bind mount for the web service:

```
version: "3.9"
services:
  web:
    build: .
    ports:
      - "8000:5000"
    volumes:
      - .:/code
    environment:
      FLASK_ENV: development
  redis:
    image: "redis:alpine"
```

The new volumes key mounts the project directory (current directory) on the host to ``/code`` inside the container, allowing you to modify the code on the fly, without having to rebuild the image. The environment key sets the FLASK_ENV environment variable, which tells flask run to run in development mode and reload the code on change. This mode should only be used in development.

## Step 6: Re-build and run the app with Compose

From your project directory, type docker-compose up to build the app with the updated Compose file, and run it.

``docker-compose up`` 

Check the Hello World message in a web browser again, and refresh to see the count increment.

    Shared folders, volumes, and bind mounts

        If your project is outside of the Users directory (cd ~), then you need to share the drive or location of the Dockerfile and volume you are using. If you get runtime errors indicating an application file is not found, a volume mount is denied, or a service cannot start, try enabling file or drive sharing. Volume mounting requires shared drives for projects that live outside of C:\Users (Windows) or /Users (Mac), and is required for any project on Docker Desktop for Windows that uses Linux containers. For more information, see File sharing on Docker for Mac, and the general examples on how to Manage data in containers.

        If you are using Oracle VirtualBox on an older Windows OS, you might encounter an issue with shared folders as described in this VB trouble ticket. Newer Windows systems meet the requirements for Docker Desktop for Windows and do not need VirtualBox.

## Step 7: Update the application

Because the application code is now mounted into the container using a volume, you can make changes to its code and see the changes instantly, without having to rebuild the image.

Change the greeting in app.py and save it. For example, change the Hello World! message to Hello from Docker!:

return 'Hello from Docker! I have been seen {} times.\n'.format(count)

Refresh the app in your browser. The greeting should be updated, and the counter should still be incrementing.

hello world in browser
Step 8: Experiment with some other commands

If you want to run your services in the background, you can pass the -d flag (for “detached” mode) to docker-compose up and use docker-compose ps to see what is currently running:

```
docker-compose up -d
docker-compose ps
```

The docker-compose run command allows you to run one-off commands for your services. For example, to see what environment variables are available to the web service:

```
docker-compose run web env
```

See docker-compose --help to see other available commands. You can also install command completion for the bash and zsh shell, which also shows you available commands.

If you started Compose with docker-compose up -d, stop your services once you’ve finished with them:

```docker-compose stop```

You can bring everything down, removing the containers entirely, with the down command. Pass --volumes to also remove the data volume used by the Redis container:

```docker-compose down --volumes```

That's all!

# Session 2: Singularity Compose


Singularity compose is intended to run a small number of container instances on your host. It is not a complicated orchestration tool like Kubernetes, but rather a controlled way to represent and manage a set of container instances, or services.

## When do I need sudo?

Singularity compose uses Singularity on the backend, so anything that would require sudo (root) permissions for Singularity is also required for Singularity compose. This includes most networking commands (e.g., asking to allocate ports) and builds from recipe files. However, if you are using Singularity v3.3 or higher, you can take advantage of fakeroot to try and get around this. The snippet below shows how to add fakeroot as an option under a build section:

```
    build:
      context: ./nginx
      recipe: Singularity.nginx
      options:
       - fakeroot
```


## Getting Started

Dependencies

Singularity Compose must use a version of Singularity 3.2.1 or greater. It's recommended to use the latest (3.3.0 release at the time of this writing) otherwise there was a bug with some versions of 3.2.1. Singularity 2.x absolutely will not work. Python 3 is also required, as Python 2 is at end of life.

```
singularity-compose.yml
```

For a singularity-compose project, it's expected to have a singularity-compose.yml in the present working directory. You can look at a simple example here, here is a version 1.0 spec (before we added networking and exec options):

```
version: "1.0"
instances:
  app:
    build:
      context: ./app
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./app:/code
      - ./static:/var/www/static
      - ./images:/var/www/images
    ports:
      - 80:80
```

and here is a version 2.0 spec that shows adding networking and exec options:

If you are familiar with docker-compose the file should look very familiar. A key difference is that instead of **"services"** we have **"instances."** And you guessed correctly - each section there corresponds to a Singularity instance that will be created. In this guide, we will walk through each of the sections in detail.
Instance folders

Generally, each section in the yaml file corresponds with a container instance to be run, and each container instance is matched to a folder in the present working directory. For example, if I give instruction to build an nginx instance from a nginx/Singularity.nginx file, I should have the following in my singularity-compose:

```
  nginx:
    build:
      context: ./nginx
      recipe: Singularity.nginx
```

The above says that I want to build a container and corresponding instance named nginx, and use the recipe Singularity.nginx in the context folder ./nginx in the present working directory. This gives me the following directory structure:
```
singularity-compose-example
├── nginx
...
│   ├── Singularity.nginx
│   └── uwsgi_params.par
└── singularity-compose.yml
```
Notice how I also have other dependency files for the nginx container in that folder. While the context for starting containers with Singularity compose is the directory location of the singularity-compose.yml, the build context for this container is inside the nginx folder. We will talk about the build command soon. First, as another option, you can just define a container to pull, and it will be pulled to the same folder that is created if it doesn't exist.
```
  nginx:
    image: docker://nginx
```

This will pull a container nginx.sif into a nginx context folder:
```
├── nginx                    (- created if it doesn't exist
│   └── nginx.sif            (- named according to the instance
└── singularity-compose.yml
```
It's less likely that you will be able to pull a container that is ready to go, as typically you will want to customize the startscript for the instance. Now that we understand the basic organization, let's bring up some instances.

## Quick Start

For this quick start, we are going to use the singularity-compose-simple example. Singularity has a networking issue that currently doesn't allow communication between multiple containers (due to iptables and firewall issues) so for now the most we can do is show you one container. First, install singularity-compose from pip:

```$ pip install singularity-compose```

Then, clone the repository:

```$ git clone https://www.github.com/singularityhub/singularity-compose-simple```

cd inside, and you'll see a singularity-compose.yml like we talked about.
```
$ cd singularity-compose-simple
$ ls
app  images  LICENSE  nginx.conf  README.md  singularity-compose.yml  static
```

Let's take a look at the singularity-compose.yml

```
version: "1.0"
instances:
  app:
    build:
      context: ./app
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./app/nginx/uwsgi_params.par:/etc/nginx/uwsgi_params.par
      - ./app/nginx/cache:/var/cache/nginx
      - ./app/nginx/run:/var/run
      - ./app:/code
      - ./static:/var/www/static
      - ./images:/var/www/images
    ports:
      - 80:80
...
```

It defines a single service, app, which has both a Django application and a nginx server with the nginx-upload module enabled. It tells us right away that the folder app is the context folder, and inside we can see dependency files for nginx and django.

```
$ ls app/
manage.py  nginx  requirements.txt  run_uwsgi.sh  Singularity  upload...
```
What we don't see is a container. We need to build that from the Singularity recipe. Let's do that.

```
$ singularity-compose build
```

Will generate an app.sif in the folder:

```
$ ls app/

app.sif manage.py  nginx  requirements.txt  run_uwsgi.sh  Singularity  upload...
```

And now we can bring up our instance!

```$ singularity-compose up```

Verify it's running:

```
$ singularity-compose ps
INSTANCES  NAME PID     IMAGE
1           app    20023    app.sif
```

And then look at logs, shell inside, or execute a command.

```
$ singularity-compose logs app
$ singularity-compose logs app --tail 30
$ singularity-compose shell app
$ singularity-compose exec app uname -a
```

When you open your browser to http://127.0.0.1 you should see the upload interface.

```
img/upload.png
```

If you drop a file in the box (or click to select) we will use the nginx-upload module to send it directly to the server. Cool!

```img/content.png```

This is just a simple Django application, the database is sqlite3, and it's now appeared in the app folder:

```
$ ls app/
app.sif  db.sqlite3  manage.py  nginx  requirements.txt  run_uwsgi.sh  Singularity  upload  uwsgi.ini
```

The images that you upload are stored in images at the root:

```
$ ls images/
2018-02-20-172617.jpg  40-acos.png  _upload 
```

And static files are in static.

```
$ ls static/
admin  css  js
```

Finally, the volumes that we specified in the singularity-compose.yml tell us exactly where nginx and the application need write. The present working directory (where the database is written) is bound to the container at /code, and nginx dependencies are bound to locations in /etc/nginx. Notice how the local static and images folder are bound to locations in the container where we normally wouldn't have write.
```
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./app/nginx/uwsgi_params.par:/etc/nginx/uwsgi_params.par
      - ./app/nginx/cache:/var/cache/nginx
      - ./app/nginx/run:/var/run
      - ./app:/code
      - ./static:/var/www/static
      - ./images:/var/www/images
```
This is likely a prime different between Singularity and Docker compose - Docker doesn't need binds for write, but rather to reduce isolation. When you develop an application, a lot of your debug will come down to figuring out where the services need to write log and similar files, which you might not have been aware of when using Docker.

Continue below to read about networking, and see these commands in detail.
Networking

When you bring the container up, you'll see generation of an etc.hosts file, and if you guessed it, this is indeed bound to /etc/hosts in the container. 

Let's take a look:
```
10.22.0.2    app
127.0.0.1    localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

This file will give each container that you create (in our case, just one) a name on its local network. Singularity by default creates a bridge for instance containers, which you can conceptually think of as a router, This means that, if I were to reference the hostname "app" in a second container, it would resolve to 10.22.0.2. Singularity compose does this by generating these addresses before creating the instances, and then assigning them to it. If you would like to see the full commands that are generated, run the up with --debug (binds and full paths have been removed to make this easier to read).

```
$ singularity instance start \
    --bind /home/vanessa/Documents/Dropbox/Code/singularity/singularity-compose-simple/etc.hosts:/etc/hosts \
    --net --network-args "portmap=80:80/tcp" --network-args "IP=10.22.0.2" \
    --hostname app \
    --writable-tmpfs app.sif app
```

Control and customization of these instances is probably the coolest (and not widely used) feature of Singularity. You can create your own network configurations, and customie the arguments to the command. Read here for more detalis.