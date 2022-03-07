# Session 3 Docker - Introduction

## Introduction to containers

In this section we provide a very short introduction to the general idea behind containers. We briefly discuss the situations when containers can be a good choice for your problem and when other solutions might be more fitting. During this training event, we focus on two containerisation technologies: Docker and Singularity. You are most likely to see these two used in the research environment, with Singularity becoming the technology of choice for High Performance Computing development (although Docker is not going from that space anytime soon).

### 1. What are containers

You may hear people say they are "running an image" or "running a container". These terms are often used interchangeably, although (like with Docker), they can mean different things - container being the running image.

The most important feature of containers, and where their real strength comes from, is that unlike "regular" applications, they can and often do perform all their work in isolation from their host OS. Your containers do not have to know what the rest of your OS is up to. They don't even have to have access to the same files as your host OS, or share the same network  (again it is possible to achieve that). Containers put a layer between your existing host filesystem and whatever you are running inside them.

### 2. What containers are not

You will often hear the expression that "containers are like VMs", or "like VMs, but lighter". This may make sense on the surface. At the end of the day, containers make use of virtualisation, **BUT** a different kind of virtualisation. There are fewer moving components in the case of containers and the end result might be the same for the end user.

Containers remove a lot of components of virtual machines though: they do not virtualise the hardware, they do not have to contain a fully-fledged guest OS to operate. They have to rely on the host OS instead. VMs sit on top of the underlying hardware, whereas containers sit on top of the host OS.

![VM vs container](media/Virtual-Machine-and-Container-Deployments.png)

NIST Special Publication 800-190, Application Container Security Guide - Scientific Figure on ResearchGate. Available from: https://www.researchgate.net/figure/Virtual-Machine-and-Container-Deployments_fig1_329973333 [accessed 28 Jan, 2022]


For a more in-depth explanation of the differences between VMs and containers, please [**see this website by the IBM Cloud Team**](https://www.ibm.com/cloud/blog/containers-vs-vms)

### 3. Why do you (and don't) need containers

* Containers will provide a reproducible work environment.
* They go beyond just sharing your code: you provide a fully-working software
with all its required dependencies (modules, libraries, etc.).
* You can build self-contained images that meet the particular needs of your
  project. No need to install software "just in case", or install something to
  be used just once.
* You are no longer tied to the software and library versions installed on your host system.
  Need python3, but only python2 is available? There is an image for that.

&nbsp;

* Your software still depends on hardware you run it on - make sure your results are consistent across different hardware architectures.
* Not the best for sharing large amounts of data (same as you wouldn't use git to share a 10GB file).
* Additional safety concerns, as e.g. Docker gives extra power to the user "out of the box". There is potential to do some damage to the host OS by an inexperienced or malicious user if your containerisation technology of choice is not configured or used properly.


## Introduction to Docker 

In this section you will learn the basics of Docker, arguably one of the most popular containerisation technologies. Since its initial release in 2013, Docker has been widely adopted in many areas of research and the ‘industry‘. It is used to provide access to e-commerce and streaming services, machine learning platforms and scientific pipelines (CERN, SKA, NASA).

More generally, you should use it as a tool for distributing consistent software environments. Currently it is only one of many existing container technologies that researchers can choose from. Two popular alternatives are Singularity (covered later) and Podman. Some solutions offer better support for High Performance Computing, while others provide a low-level control of the environment. There really is something for everyone.

### In this section you will learn

- [**How to start Docker containers**](#1-running-first-docker-container)
- [**How to manage your Docker images**](#2-managing-docker-images)
- [**How to manage your Docker containers**](#3-managing-docker-containers)
- [**How to work with Docker containers**](#4-working-with-docker-containers)

### 1. Running first Docker container

For our first example, we will run a short Docker command to download the *Hello World* of **Docker images** and start our very first **Docker container**.

```bash

$ docker container run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete 
Digest: sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

#### **Let's examine the command and the generated output step by step.**

- **The command that we execute**
  
    ```bash
    $ docker container run hello-world
    ...
    ```

    instructs Docker that we would like to start a container using a `hello-world` image. This command can also be written as `docker run hello-world`, omitting the `container` part. This change was [**introduced in 2017**](https://www.docker.com/blog/whats-new-in-docker-1-13/) with a major overhaul of the Docker CLI (Command Line Interface). If the version of Docker installed on your machine comes from before these changes were introduced (we strongly recommend that you upgrade it due to security reasons), the full command will not work and you will have to use the short version. This section however is written with the new versions of Docker in mind and will **follow the convention of using the extended versions of the commands**.

- **The next few lines**

    ```docker
    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    b8dfde127a29: Pull complete 
    Digest: sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
    Status: Downloaded newer image for hello-world:latest
    ```

    tells us that Docker was not able to find this image on our machine and has to download it from the external repository. If you have used this particular image in the past, you will not see any information about Docker trying to download the image.

    You could also separate the `docker container run ...` command above into two instructions:

    ```bash
    $ docker image pull hello-world
    $ docker container run hello-world
    ...
    ```

    In this case we are very explicit and tell Docker to first download (pull) the image from the external repository and then start the container based on that image. If you already have the image on your host machine, you can skip the `pull` command. In this case, including the `docker image pull` separately can be seen as a bit redundant as Docker takes care of any missing images with `docker container run`. You can however just pull the image and not run it at all, or pull it when you have access to the Internet and later start the container when you are offline.

- **The rest of the output**

    The rest of the output is the most interesting part. It is an
    innocent-looking list, but as items 3 and 4 from that list explain, that
    particular part of the output was generated INSIDE the container and only
    then sent back to the terminal for us to see. That means we have **successfully
    created and run our very first Docker container**.

### 2. Managing Docker images

- **Examine local images**

    How does Docker know whether it has to download the image or that the image is already present on your computer? Can you have this knowledge as well? Docker keeps track of all the images and layers that you download. There usually is a directory on your system which contains all the currently downloaded images and the associated SHA256 keys used to identify them. This ensures that the same layer or image is not downloaded twice and can be reused if necessary. For an in-depth description on how Docker stores images, please refer to [**this help guide**](https://docs.docker.com/storage/storagedriver/).

    The placement and structure of relevant directories can be different depending on your Docker installation and require root permissions to access. There is however a short command that lists all the locally available images:

    ```bash
    $ docker image ls
    ...
    ```

    Depending on how long (if at all) you have been using Docker for, the output will show only a single image that we have used above or multiple (as many as few tens of) images, as seen below (this is what I see when I run the above command on my work PC - **you will see something different**)

    ```docker
    REPOSITORY                 TAG                      IMAGE ID       CREATED         SIZE
    <none>                     <none>                   670fa2d9f98c   2 months ago    3.14GB
    <none>                     <none>                   2187b33a009b   2 months ago    714MB
    <none>                     <none>                   16b9ad7fc05d   2 months ago    3.12GB
    python                     3.7-alpine               6c59ae21a586   2 months ago    41.6MB
    redis                      alpine                   f7cdff500577   2 months ago    32.3MB
    ubuntu                     18.04                    3339fde08fc3   3 months ago    63.3MB
    nvidia/cuda                10.0-devel-ubuntu18.04   f1cb864ecfaf   3 months ago    2.24GB
    nvidia/cuda                10.2-devel-ubuntu18.04   5fe1e15ef79b   3 months ago    2.96GB
    hello-world                latest                   d1165f221234   3 months ago    13.3kB
    jupyter/scipy-notebook     latest                   dab5e9968512   7 months ago    2.7GB
    nvidia/cuda                9.2-cudnn7-devel         0a6a8962363e   8 months ago    2.88GB
    nvidia/cuda                9.2-base                 7def1f9b9d8d   9 months ago    80.8MB
    nvidia/cuda                9.2-base-ubuntu18.04     7def1f9b9d8d   9 months ago    80.8MB
    nvidia/cuda                9.2-devel-ubuntu18.04    b06eca0e3d4a   9 months ago    2.2GB
    cuda                       8.0-base-ubuntu16.04     f240c010c4f2   10 months ago   142MB
    ubuntu                     16.04                    005d2078bdfa   14 months ago   125MB
    rabbitmq                   3.8.2                    b8956a8129ef   16 months ago   151MB
    nvidia/cuda                9.2-devel-ubuntu16.04    1874839f75d5   19 months ago   2.35GB
    nvidia/cuda                10.0-base-ubuntu18.04    841d44dd4b3c   19 months ago   110MB
    ```

    If you know its name, you can list just a specific image:

    ```bash
    $ docker image ls hello-world
    ...
    ```

    or even use wildcards if you are not sure about the full image name (was it `nvidia/cuda` or `nvidia/CUDA`?):

    ```bash
    $ docker image ls nvidia/*
    REPOSITORY    TAG         IMAGE ID       CREATED        SIZE
    nvidia/cuda   10.1-base   bfa75f8b799e   6 months ago   105MB
    nvidia/cuda   9.2-base    5eabb7ffec15   6 months ago   80.7MB
    ```

    This is the default output that tells us that there are two images starting with `nvidia/` available locally on our machine, with the `9.2-base` and `10.1-base` tags. You can treat the tags as an extra bit of information about the version of the image. Next comes the image ID, which is a shortened version of the SHA256 key (or digest, using Docker vocabulary) used to identify the image and information on when the image was created. This information refers to when the image was first built and not pulled.

    We have used the most basic version of the image listing command, with the exception of using wildcards. For a complete reference and advanced examples, such as formatting and filtering, please visit [**this docker images reference**](https://docs.docker.com/engine/reference/commandline/images/). **Quick note:** the above document refers to a `docker images` command, which is *an alias* to the full `docker image ls` command. All the options however will work with both versions of this command. You can still use it as a reference for the `--format` and `--filter` options.

- **Remove the image**

    We made sure that the container was no longer running and then we removed it. What if we want to go one step further and want to get rid of the underlying image? Docker has a fairly intuitive command for that as well - instead of removing a container, we tell it to remove the image instead:

    ```bash
    $ docker image rm  hello-world
    Untagged: hello-world:latest
    Untagged: hello-world@sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
    Deleted: sha256:d1165f2212346b2bab48cb01c1e39ee8ad1be46b87873d9ca7a4e434980a7726
    Deleted: sha256:f22b99068db93900abe17f7f5e09ec775c2826ecfe9db961fea68293744144bd
    ```

    In this case we use the **image name** and Docker prints out the confirmation that it was removed successfully.

### 3. Managing Docker containers

- **Examine currently running containers**

    In the same way we listed the images currently available locally on our machine, we can examine currently running containers:

    ```bash
    $ docker container ls
    CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
    ```

    We see nothing really useful. This means there are no containers running at this moment in time.

    When we launched our `hello-world` container above, it started, it did the job it was designed to do and it stopped immediately. In the case of the `hello-world` image, the designers decided it should print out a helpful output once the container is launched successfully, but that may not always be the case.

    We still have an option to check whether our container was started at all. We can force Docker to list *all* the containers with the extra `-a` option:

    ```bash
    $ docker container ls -a
    CONTAINER ID   IMAGE                   COMMAND                  CREATED        STATUS                    PORTS     NAMES
    7dd021096f75   hello-world             "/hello"                 3 hours ago    Exited (0) 3 hours ago              trusting_herschel
    ```

    In this case we actually get some useful information about our container we have just run. We see that we launched the container, it ran and it exited with code 0, meaning a successful, error-free execution. We can also see when the container was created and when it completed its execution. As you have seen, we get the results from the `hello-world` container pretty much immediately, and therefore the `CREATED` and `Exited` times are the same, but generally this is not the case.

    Every container has a "human-readable" name assigned to it at launch. It makes it easier to refer to the container using that name instead of the container ID, listed in the first column of the above output. These names are randomly generated from a list of adjectives and famous scientists and Docker does not guarantee the name will repeat for the same container (it is extremely unlikely your container will have the same name as the one listed above).

    It is therefore important to provide a name with the `run` command using the `--name` option to ensure reproducible and predictable deployment. This is especially important when you run multiple  containers at the same time, e.g. making it easy to differentiate front- and backend Node-based containers that can have the same underlying image, or rely on automatic scripts that require predictable names.

    If you are running containers right now, you will see them as "Up", as below

    ```bash
    $ docker container ls -a
    CONTAINER ID   IMAGE            COMMAND                  CREATED        STATUS         PORTS     NAMES
    f1d9fa05caae   rabbitmq:3.8.2   "docker-entrypoint.s…"   2 months ago   Up 5 minutes             rabid_rabbit
    ```

- **Remove the container**

    Exited containers can be thought of as being hibernated - they are not running, their internal state is saved and they can be woken up and run again. When we are satisfied with the results provided by our container launch,  we might need to remove it. We can do this with the help of `container rm` command:

    ```bash
    $ docker container rm trusting_herschel
    trusting_herschel
    ```

    Here we used the Docker-assigned name to remove the container. We can also use the container ID to achieve the same result. Make sure you replace the name above with the name or the container ID that you got by running the `docker container ls -a` command.

### 4. Working with Docker containers

Using a `hello-world` image is one thing, actually doing some work with containers is another. As interesting as it might be, the above image doesn't do much beyond printing out the message we have seen at the start. Not very useful from the astrophysics perspective.

We are going to experiment with a much more useful image: an official Python 3.10.2 image based on Debian bullseye (it's a slimmed down version to be more specific - 123MB vs over 900MB for the 'traditional' bullseye).

Instead of just running the image, we fill first pull it:

```bash
$ docker image pull python:3.10.2-slim-bullseye
3.10.2-slim-bullseye: Pulling from library/python
a2abf6c4d29d: Pull complete 
27003db43ed4: Pull complete 
a41b33cb9814: Pull complete 
6ed4b1851bbe: Pull complete 
51db3bf96e69: Pull complete 
Digest: sha256:e7adb53c5bb371c55148dfea3c4a72f34d047c87e89b8958f8da759abe9c3f1e
Status: Downloaded newer image for python:3.10.2-slim-bullseye
docker.io/library/python:3.10.2-slim-bullseye
```

If we just run it, we won't get any output like when using the `hello-world` image (we will also explicitly test whether the container is running):

```bash
$ docker container run --name python-test python:3.10.2-slim-bullseye

$ docker container ls -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                      PORTS     NAMES
67b36e6034d2   python:3.10.2-slim-bullseye   "python3"                27 seconds ago   Exited (0) 22 seconds ago             python-test
```

The container exits immediately, just like the `hello-world` one. That's because by default, there is no work to be done. We can change that. We can remove the container like we have done before, but this time, we can use the name we have provided explicitly with `--name` flag (I used `python-test`, feel free to name your container something else, just make sure you change the name in the commands that use it).

```bash
$ docker container rm python-test
python-test
```

I removed this container because I want to reuse the name and also keep my Docker containers to bare minimum. We can use the same image to actually start executing some code from INSIDE the running container. We will start slowly, I want to find out a version of Python available inside the running container:

```bash
$ docker container run --name python-test python:3.10.2-slim-bullseye python3 --version
Python 3.10.2
```

That's the version we expected to see based on the image we're using. Most importantly, this is the version that is shipped inside this Python image and executed inside our container. You do not have to have Python installed on your host machine, or can have a completely different version (for example I am running 3.8.5 on my host) - Python inside your container is not even aware of that other version.

But let's do some actual work. We will do it in two ways. First we will launch a very simple script that you can download from [**here**](files/script.py). You do not have to be familiar with Python to understand what it does: we simply print out a welcome message and perform some very basic operations.

As we have mentioned before, containers by default do not know much about their host machine. Most importantly, they do not share any files with it, so they will not be able to find our Python script and run it. We therefore have to make it available inside the container.  We launch our image it with the additional options that *mount* the data inside the container:

```bash
$ docker container run --name python-test-2 --mount type=bind,source=$(pwd),target=/scripts python:3.10.2-slim-bullseye python3 /scripts/script.py
Welcome to Docker Python
8
13
2.0
0.5
We  are  done!
```

The `--mount` option may seem a bit verbose if you have not seen it before, but it should be fairly easy to understand. First we specify the `type=bind` to tell Docker to use a bind mount (it is not the only type of mount we can have, but we are not going to cover them here). We then provide two [key]:[value] pairs separated by a comma ( , ) that specify the source and target directory and/or file. As we are using distinctive keys, the order of the pairs is not important, but try to keep it in some order for consistency.

Here we make only a single file available inside the container, but it is also possible to make whole directories available and bound to a directory inside your container.

**IMPORTANT:** bind mounts do not create a copy of the data! Your data is shared between your host and container environments. Any changes that you make to your data on the host side, will be visible inside the container and vice versa. Be careful if you are manipulating any data that you cannot afford to corrupt - it might be safer to make a copy in this case!

Making data available inside your container at a runtime has some obvious drawbacks. With that approach, your data and your software are no longer placed in a single environment. You have to rely on your end-users to  provide their own data or to be able to access your data from external sources. This can also increase the development time for your software, as you have to take into account and prevent errors that users can introduce if their data does not meet your requirements. The decision on whether to include the data inside your image during the build time or as a mount during the runtime will be entirely up to you and will depend on your project and user requirements.

Second approach can be running our image *interactively*. In this case our container will behave like a usual Python CLI interpreter and we can treat it as such.

```bash
$ docker container run --name python-test-3 -it python:3.10.2-slim-bullseye
Python 3.10.2 (main, Jan 18 2022, 20:00:03) [GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("I'm inside the container")
I'm inside the container
```

However, we are not limited to running just Python. This particular image comes with bash installed, so we can make use of it. We can launch an interactive bash session and treat this container like a regular terminal (albeit with many things missing):

```bash
$ docker container run --name python-test-4 -it python:3.10.2-slim-bullseye /bin/bash
root@2decf291ee44:/# pwd
/
root@2decf291ee44:/# ls -l
total 64
drwxr-xr-x   1 root root 4096 Jan 18 20:02 bin
drwxr-xr-x   2 root root 4096 Dec 11 17:25 boot
drwxr-xr-x   5 root root  360 Jan 22 23:36 dev
drwxr-xr-x   1 root root 4096 Jan 22 23:35 etc
drwxr-xr-x   2 root root 4096 Dec 11 17:25 home
...
```

This way you can use containers not just for one-off jobs, but also use them for interactive work.

**IMPORTANT:**  Launching our container the way we did just now may seem innocent enough, but comes with a **serious security problem** If you look closely at the command line prompt, we are listed as a user `root`, meaning we have administrative privileges inside the container. This becomes a very serious issue if we give our container access to any external resources such as host disks or network. We usually do not perform our day-to-day activities with privileged accounts and we shouldn't do that inside our containers either.

We can change this default behaviour by providing a `--user` flag to our `run` command:

```bash
$ docker container run --user 1000:1000 --name python-test-5 -it python:3.10.2-slim-bullseye /bin/bash
I have no name!@46023ae04069:/$
```

We have launched a new container with user ID 1000 and group ID 1000 (the format is `--user [user ID]:[group ID]`. As we have not created this user inside the container, Docker has no idea who that user is exactly, but we can still perform various tasks with the same permissions as the original user on the host OS.

# Session 3 Singularity

## Introduction to Singularity

What IS a software container anyway? (And what's it good for?)

A container allows you to stick an application and all of its dependencies into a single package. This makes your application portable, shareable, and reproducible.

Containers foster portability and reproducibility because they package ALL of an applications dependencies... including its own tiny operating system!

This means your application won't break when you port it to a new environment. Your app brings its environment with it.

Here are some examples of things you can do with containers:

    Package an analysis pipeline so that it runs on your laptop, in the cloud, and in a high performance computing (HPC) environment to produce the same result.
    Publish a paper and include a link to a container with all of the data and software that you used so that others can easily reproduce your results.
    Install and run an application that requires a complicated stack of dependencies with a few keystrokes.
    Create a pipeline or complex workflow where each individual program is meant to run on a different operating system.

### How do containers differ from virtual machines (VMs)

Containers and VMs are both types of virtualization. But it's important to understand the differences between the two and know when to use each.

Virtual Machines install every last bit of an operating system (OS) right down to the core software that allows the OS to control the hardware (called the kernel). This means that VMs:

    Are complete in the sense that you can use a VM to interact with your computer via a different OS.
    Are extremely flexible. For instance you an install a Windows VM on a Mac using software like VirtualBox.
    Are slow and resource hungry. Every time you start a VM it has to bring up an entirely new OS.

Containers share a kernel with the host OS. This means that Containers:

    Are less flexible than VMs. For example, a Linux container must be run on a Linux host OS. (Although you can mix and match distributions.) In practice, containers are only extensively developed on Linux.
    Are much faster and lighter weight than VMs. A container may be just a few MB.
    Start and stop quickly and are suitable for running single apps.

Because of their differences, VMs and containers serve different purposes and should be favored under different circumstances.

    VMs are good for long running interactive sessions where you may want to use several different applications. (Checking email on Outlook and using Microsoft Word and Excel).
    Containers are better suited to running one or two applications, often non-interactively, in their own custom environments.

### Docker

Docker is currently the most widely used container software. It has several strengths and weaknesses that make it a good choice for some projects but not for others.

**philosophy**

Docker is built for running multiple containers on a single system and it allows containers to share common software features for efficiency. It also seeks to fully isolate each container from all other containers and from the host system.

Docker assumes that you will be a root user. Or that it will be OK for you to elevate your privileges if you are not a root user. See https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface for details.

**strengths**

    Mature software with a large user community
    Docker Hub!
        A place to build and host your containers
        Fully integrated into core Docker
        Over 100,000 pre-built containers
        Provides an ecosystem for container orchestration
    Rich feature set

**weaknesses**

    Difficult to learn
        Hidden innards
        Complex container model (layers)
    Not architected with security in mind
    Not built for HPC (but good for cloud)

Docker shines for DevOPs teams providing cloud-native micro-services to users.

### Singularity

Singularity is a relatively new container software invented by Greg Kurtzer while at Lawrence Berkley National labs and now developed by his company Sylabs. It was developed with security, scientific software, and HPC systems in mind.

**philosophy**

Singularity assumes (more or less) that each application will have its own container. It does not seek to fully isolate containers from one another or the host system.

Singularity assumes that you will have a build system where you are the root user, but that you will also have a production system where you may or may not be the root user.

**strengths**

    Easy to learn and use (relatively speaking)
    Approved for HPC (installed on some of the biggest HPC systems in the world)
    Can convert Docker containers to Singularity and run containers directly from Docker Hub
    Singularity Container Services!
        A place to build and share your containers securely

**weaknesses**

    Younger and less mature than Docker
    Smaller user community (as of now)
    Under active development (must keep up with new changes)

Singularity shines for scientific software running in an HPC environent. We will use it for the remainder of the class.

## Installing and Set-up Singularity


Here we will install the latest tagged release from GitHub. If you prefer to install a different version or to install Singularity in a different location, see these Singularity docs.

We're going to compile Singularity from source code. First we'll need to make sure we have some development tools and libraries installed so that we can do that. On Ubuntu, run these commands to make sure you have all the necessary packages installed.

```
$ sudo apt-get update

$ sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev \
    squashfs-tools libseccomp-dev wget pkg-config git cryptsetup debootstrap
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum -y update 

$ sudo yum -y groupinstall 'Development Tools'

$ sudo yum -y install wget epel-release

$ sudo yum -y install debootstrap.noarch squashfs-tools openssl-devel \
    libuuid-devel gpgme-devel libseccomp-devel cryptsetup-luks
```

Singularity v3.0 was completely re-written in Go. We will need to install the Go language so that we can compile Singularity. This procedure consists of downloading Go in a compressed archive, extracting it to /usr/local/go and placing the appropriate directory in our PATH. For more details, check out the Go Downloads page.

```
$ wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz

$ sudo tar --directory=/usr/local -xzvf go1.13.linux-amd64.tar.gz

$ export PATH=/usr/local/go/bin:$PATH
```

Next we'll download a compressed archive of the source code (using the the wget command). Then we'll extract the source code from the archive (with the tar command).

```
$ wget https://github.com/singularityware/singularity/releases/download/v3.5.3/singularity-3.5.3.tar.gz

$ tar -xzvf singularity-3.5.3.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity

$ ./mconfig

$ cd builddir

$ make

$ sudo make install
```


If everything went according to plan, you now have a working installation of Singularity. Simply typing singularity will give you a summary of all the commands you can use. Typing singularity help <command> will give you more detailed information about running an individual command.

You can test your installation like so:

```
$ singularity run library://godlovedc/funny/lolcow
```

You should see something like the following.

```
INFO:    Downloading library image
 _______________________________________
/ Excellent day for putting Slinkies on \
\ an escalator.                         /
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Your cow will likely say something different (and be more colorful), but as long as you see a cow your installation is working properly.

This command downloads and "runs" a container from Singularity Container Library. (We'll be talking more about what it means to "run" a container later on in the class.)

In a following exercise, we will learn how to build a similar container from scratch. But right now, we are going to use this container to execute a bunch of basic commands and just get a feel for what it's like to use Singularity.

## Starting with Singularity containers

In this tutorial we will work with a containerization system called Singularity, which has many features that make it interesting for workflow development and long-term reproducibility.

We will cover the following:

- Why Singularity
- Preparing the working environment
- Basic use of Singularity
- Your own Container Hub
- Creating our first container
- Share your work


Singularity is a container platform (like Docker, PodMan, Moby, LXD, ... among other). It allows you to create and run containers that package up pieces of software in a way that is portable and reproducible. You can build a container using Singularity on your laptop, and then run it on many of the largest HPC clusters in the world, local university or company clusters, a single server, in the cloud, or on a workstation down the hall. Your container is a single file, and you don’t have to worry about how to install all the software you need on each different operating system.


**Advantages:**

- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on some of the biggest HPC systems in the world)
- Can convert Docker containers to Singularity and run containers directly from Docker Hub
- [SingularityHub](https://cloud.sylabs.io/)


**Disadvantages:**

- Less mature than Docker
- Smaller user community
- Under very active development 

Singularity is focused for scientific software running in an HPC environent. 

### Aims

- Mobility of Compute
- Reproducibility
- User Freedom
- Support on Existing Traditional HPC

### The Singularity container image

Singularity makes use of a container image file, which physically includes the container. 

#### Supported container formats

- `squashfs`: the default container format is a compressed read-only file system that is widely used for things like live CDs/USBs and cell phone OS’s
- `ext3`: (also called writable) a writable image file containing an ext3 file system that was the default container format prior to Singularity version 2.4
- `directory`: (also called sandbox) standard Unix directory containing a root container image
- `tar.gz`: zlib compressed tar archive
- `tar.bz2`: bzip2 compressed tar archive
- `tar`: uncompressed tar archive


#### Supported Unified Resource Identifiers (URIs)

Singularity also supports several different mechanisms for obtaining the images using a standard URI format.

- `shub://` Singularity Hub is the registry for Singularity containers like DockerHub.
- `docker://` Singularity can pull Docker images from a Docker registry.
- `instance://` A Singularity container running as service, called an instance, can be referenced with this URI.


#### Copying, sharing, branching, and distributing your image

A primary goal of Singularity is mobility. The single file image format makes mobility easy. Because Singularity images are single files, they are easily copied and managed. You can copy the image to create a branch, share the image and distribute the image as easily as copying any other file you control!


### Preparing the work environment

You will need a Linux system to run Singularity natively. Options for using Singularity on Mac and Windows machines, along with alternate Linux installation options are discussed in the installation guides.

So after this part we assume that you have Singularity installed for your system.

### The Singularity Usage Workflow

There are generally two groups of actions you must implement on a container; management (building your container) and usage.

![Workflow](https://sylabs.io/guides/2.5/user-guide/_images/flow.png)

On the left side, you have your build environment: a laptop, workstation, or a server that you control. Here you will (optionally):

- develop and test containers using --sandbox (build into a writable directory) or --writable (build into a writable ext3 image)
- build your production containers with a squashfs filesystem.

And on the right side, a consumer profile for containers.


### Singularity Commands

To work with the Singularity there are really only a few commands that provide us with all the operations:

- `build` : Build a container on your user endpoint or build environment
- `exec` : Execute a command to your container
- `inspect` : See labels, run and test scripts, and environment variables
- `pull` : pull an image from Docker or Singularity Hub
- `run` : Run your image as an executable
- `shell` : Shell into your image

### Run a test

Go to the environment where you have Singularity installed to do some tests. You can test your installation like so:

```
vagrant@ska-training:~$ singularity pull docker://godlovedc/lolcow
```

This command will simply download an image that already exists in Docker (`docker://godlovedc/lolcow` from DockerHub: [lol docker](https://hub.docker.com/r/godlovedc/lolcow) ), and store it as a local file with SIF format.


Confirms you have a file named: `lolcow_latest.sif`: 

```
ls -l lolcow_latest.sif
```

Then, we execute the image as an executable, simply typing: 

```
vagrant@ska-training:~$ singularity run lolcow_latest.sif
 ____________________
< Beware of Bigfoot! >
 --------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

### Using an image for SKA training

We have prepared an image that is available in the Singularity image repository ( [link here](https://cloud.sylabs.io/library/manuparra/ska/skatrainingplot) ). This container image contains the following:

- It creates a python framework that includes the python libraries: `scipy`, `numpy` and `mathplotlib`.
- It includes a python application that draws a plot in a output file.

The source code to generate it is located [here](link) (we will work on it later).

### Pulling the new image

This download takes about 300 MBytes.

```
vagrant@ska-training:~$ singularity pull library://manuparra/ska/skatrainingplot:latest
```

After that you will see a new file named `skatrainingplot_latest.sif` with the downloaded image.


### Entering the images from a shell

The shell command allows you to open a new shell within your container and interact with it as though it were a small virtual machine. This would be very similar to what you do with docker and run a shell with bash (`docker run .... /bin/bash`):

```
vagrant@ska-training:~$  singularity shell skatrainingplot_latest.sif
```

Once executed you will be connected to the container (yopu will see a new prompt):

```
Singularity skatrainingplot_latest.sif:~> 

```

From here you can interact with container, and  you are the *same user* as you are on the host system.

```
Singularity skatrainingplot_latest.sif:~> whoami

vagrant

Singularity skatrainingplot_latest.sif:~> id

uid=900(vagrant) gid=900(vagrant) groups=900(vagrant),27(sudo)

```

**NOTE**

If you use Singularity with the shell option and and image from `library://`, `docker://`, and `shub://` URIs this creates an ephemeral container that disappears when the shell is exited.

### Executing command from a container

The exec command allows you to execute a custom command within a container by specifying the image file. For instance, to execute the cowsay program within the `skatrainingplot_latest.sif` container:

To do that, type `exit` from Singularity container and you will return to your host machine. Here, we can execute commands within the container, but not entering on the container. Executing something and then exiting at the same time 

```
vagrant@ska-training:~$ singularity exec skatrainingplot_latest.sif python3
Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.

``` 
This way you are running `python3` from the container with all the libraries that the container has provided. And once we exit the python shell we return to the host. 

Type `CTRL+D` to exit from the python3 shell, and you will return to your host machine.

This is very interesting because we can run something in the container environment that does something, in this case the container provides specific libraries, which are not on the host machine. To try this, we run the following on the host machine:

```
vagrant@ska-training:~$ python3
Python 3.6.9 (default, Dec  8 2021, 21:08:43) 
[GCC 8.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'numpy'

```
You can see that we haven't installed `numpy`, so we can't use `numpy`.

Now we execute `python3` within the container:

```
vagrant@ska-training:~$ singularity exec skatrainingplot_latest.sif python3
Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy

```

Our container has `numpy` and other libraries installed, so you can use them.

In this way we could use the container to execute a script that we have created and run it with all the environment that enables the container, in this case some libraries in some specific versions. 
This is important because it allows to isolate the host environment with our development, with this we could have different containers with different library versions for example. To test it, we create a `python` file in our host machine:

```
vi test.py
```

And we add the following content:

```
import numpy as np
a = np.arange(15).reshape(3, 5)
print(a)
```

Then we can execute it typing the following:


```
vagrant@ska-training:~$  singularity exec skatrainingplot_latest.sif python3 test.py
[[ 0  1  2  3  4]
 [ 5  6  7  8  9]
 [10 11 12 13 14]]

```

If we try it on our host machine:

```
vagrant@ska-training:~ $ python3 test.py 
Traceback (most recent call last):
  File "test.py", line 1, in <module>
    import numpy as np
ModuleNotFoundError: No module named 'numpy'
```


### Running a container

Singularity containers can execute runscripts. That is, they allow that when calling them from Singularity with the exec option, they execute a scripts that define the actions a container should perform when someone runs it.

In this example for `lolcow_latest.sif` you can see a message, that is generated because for this container the developer has created a start point when you call Singularity with the option `run`.

```
vagrant@ska-training:~$ singularity run lolcow_latest.sif
 _____________________________________
/ You have been selected for a secret \
\ mission.                            /
 -------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

`run` also works with the `library://`, `docker://`, and `shub://` URIs. This creates an ephemeral container that runs and then disappears.

Now we try with our container:

```
vagrant@ska-training:~/builkd$ singularity run skatrainingplot_latest.sif 
-----------------------------------------------
SKA training: Git and Containers
Plot generated in example.png by default, please provide an output plot file
```

And now you can see that this command has generated an image called `example.png`.

With this option we can run an application already predefined in the container, but this is not always the default option and depends on how the container was built.

```
vagrant@ska-training:~/builkd$ singularity run skatrainingplot_latest.sif myplotforska.png
-----------------------------------------------
SKA training: Git and Containers
Plot generated in myplotforska.png file.
```

This command has generated an image called `myplotforska.png`.


**It is important to comment that a key feature is that from the container we have access to the host files in a transparent way.**

For instance:

```
vagrant@ska-training:~$ singularity shell skatrainingplot_latest.sif 
```

And then if you type `ls -l`, you will see your own files from the folder you were. *You are in the container* :smile:. 

So here, you can create a file:

```
Singularity skatrainingplot_latest.sif :~> echo "This is a SKA training" > hello.txt
```

You can see the file created inside the container but it is also in your host folder.

```
Singularity skatrainingplot_latest.sif :~> exit
vagrant@ska-training:~$ ls -l
...
hello.txt
...
```

**By default Singularity bind mounts `/home/$USER`, `/tmp`, and `$PWD` into your container at runtime.**

### Build images

And now the question is, how can I create my own container with my software?

With `build` option you can convert containers between the formats supported by Singularity. And you can use it in conjunction with a Singularity definition file to create a container from scratch and customized it to fit your needs.


### Downloading a container from Docker Hub

You can use build to download layers from Docker Hub and assemble them into Singularity containers.

```
$ sudo singularity build lolcow.sif docker://godlovedc/lolcow
```

### Building containers from Singularity definition files

Singularity definition files,  can be used as the target when building a container. Using the Docker equivalence, these would be the Dockerfile's we use to build an image.

Here you can see an example of a definition file `lolcow.def`:

```
Bootstrap: docker
From: ubuntu:16.04

%post
    apt-get -y update
    apt-get -y install fortune cowsay lolcat

%environment
    export LC_ALL=C
    export PATH=/usr/games:$PATH

%runscript
    fortune | cowsay | lolcat
```

We can build it with:

```
$ sudo singularity build lolcow.sif lolcow.def
```

Now we can see how the test container we have made for ska is built (`skatraining.def`):

```
Bootstrap: docker
From: ubuntu:20.04

%post
apt-get update && apt-get install -y vim python3 python3-pip
pip3 install matplotlib
pip3 install scipy
pip3 install numpy

cat << EOF > /plot.py

import numpy as np
import sys
from scipy.interpolate import splprep, splev

import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.patches import PathPatch

plotname = sys.argv[1] if len(sys.argv)>1 else "example.png"

N = 400
t = np.linspace(0, 3 * np.pi, N)
r = 0.5 + np.cos(t)
x, y = r * np.cos(t), r * np.sin(t)
fig, ax = plt.subplots()
ax.plot(x, y)
plt.xlabel("X value")
plt.ylabel("Y value")
plt.savefig(plotname)
print("-----------------------------------------------")
print("SKA training: Git and Containers")
print("Plot generated in " + plotname + " file.")
print("-----------------------------------------------")
EOF 

%runscript
  if [ $# -ne 1 ]; then
        echo "-----------------------------------------------"   
        echo "SKA training: Git and Containers"   
        echo "Plot generated in example.png by default, please provide an output plot file"
        exit 1
  fi
  python3 /plot.py $1
```

Then we build with:

```
$ sudo singularity build skatraining.sif skatraining.def
```

We now explain each of the components of the build file:

- Where the image comes from and what is the component:
```
Bootstrap: docker
From: ubuntu:20.04
```

- What will be done in the image to build it. In our case include some packages and libraries, and add a python file that makes some plots.
```
%post
```


- What we will execute when the container is called with the `run` option.
```
%runscript
```

And this is all for now with containers. In the following training sessions we will go deeper into the use of containers.

