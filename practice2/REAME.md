# Practice 2

Implementing facial recognition within a Functions-as-a-Service platform


**Objectives of the practice:**

- Install and deploy tool and cloud platform for container orchestration: Kubernetes.
- Deploy the functionality of the functions catalogue and functions service through OpenWisk or OpenFaaS.
- Implement a scalable function to recognise images of people. 

## Description of the practice

Function-as-a-Service (FaaS) is a serverless way to execute modular pieces of code on the edge. FaaS lets developers write and update a piece of code on the fly, which can then be executed in response to an event, such as a user clicking on an element in a web application. This makes it easy to scale code and is a cost-efficient way to implement microservices.

**What are the advantages of using FaaS?**

*Improved developer velocity*: With FaaS, developers can spend more time writing application logic and less time worrying about servers and deploys. This typically means a much faster development turnaround.

*Built-in scalability*: Since FaaS code is inherently scalable, developers don’t have to worry about creating contingencies for high traffic or heavy use. The serverless provider will handle all of the scaling concerns.

*Cost efficiency*:Unlike traditional cloud providers, serverless FaaS providers do not charge their clients for idle computation time. Because of this, clients only pay for as much computation time as they use, and do not need to waste money over-provisioning cloud resources.


**What are the drawbacks of FaaS?**

*Less system control*:Having a third party manage part of the infrastructure makes it tough to understand the whole system and adds debugging challenges.

*More complexity required for testing*: It can be very difficult to incorporate FaaS code into a local testing environment, making thorough testing of an application a more intensive task.

**Why serverless**

Serverless computing offers a number of advantages over traditional cloud-based or server-centric infrastructure. For many developers, serverless architectures offer greater scalability, more flexibility, and quicker time to release, all at a reduced cost. With serverless architectures, developers do not need to worry about purchasing, provisioning, and managing backend servers. However, serverless computing is not a magic bullet for all web application developers.

**What you get with FaaS**

![FaaS](https://cf-assets.www.cloudflare.com/slt3lc6tev37/7nyIgiecrfe9W6TfmJRpNh/dfc5434659e31300d1918d4163dfb263/benefits-of-serverless.svg)

Serverless computing allows developers to purchase backend services on a flexible ‘pay-as-you-go’ basis, meaning that developers only have to pay for the services they use. This is like switching from a cell phone data plan with a monthly fixed limit, to one that only charges for each byte of data that actually gets used.

The term ‘serverless’ is somewhat misleading, as there are still servers providing these backend services, but all of the server space and infrastructure concerns are handled by the vendor. Serverless means that the developers can do their work without having to worry about servers at all.

**Is Serverless for you**

Developers who want to decrease their go-to-market time and build lightweight, flexible applications that can be expanded or updated quickly may benefit greatly from serverless computing.

Serverless architectures will reduce costs for applications that see inconsistent usage, with peak periods alternating with times of little to no traffic. For such applications, purchasing a server or a block of servers that are constantly running and always available, even when unused, may be a waste of resources. A serverless setup will respond instantly when needed and will not incur costs when at rest.

Also, developers who want to push some or all of their application functions close to end users for reduced latency will require at least a partially serverless architecture, since doing so necessitates moving some processes out of the origin server.

**And now, what else? - What to implement**

Now that you have been introduced to what Serverless is all about, I think it is time to discuss what this practice is all about. 

The main idea of the practice is to create a function or several functions that allow you to:

- Capture/collect an image (e.g. from a URL) as input to the function.
- The function must detect the faces that appear
- The function should return the image with the detected faces framed in a rectangle.

For this you will need the following in terms of platforms/tools to install:

- Install microk8s (or minikube). 
- Install a RAS platform: OpenFaaS or OpenWisk on top of the Kubernetes platform above.

Having done this, you will then need to create the role within the platform and add it to the role platform catalog.

**For function development you can choose any language that is supported by the functions-as-a-service platform. If you want to use another language for function design, you will need to implement the function from a container.**

If you are using node.js, java, or other languages, check the following examples:

- R https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- GoLang https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/java
- Java https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions
- Node https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/node
- Python https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/python


## Function design (template with Python)

For the design of the face recognition function you can use pre-trained models that allow you to do the detection without having to create a model from scratch. 

The pseudocode function could look like the following:

```
def ffunction(input_URL)
  model=load_faces_models
  image=read_image_from_URL
  faces=detect_faces(model,image)
  imagefaces=add_detection_frames_to_the_original_image(faces, image)
  return imagefaces or save_image(output_URL)  
```

Specifically for the OpenFaaS platform example, the function would be created in this way:

```
$ faas-cli new --lang python facesdetection-python
```

This creates three files for you:

```
facesdetection-python/handler.py
facesdetection-python/requirements.txt
facesdetection-python.yml
```

Let's edit the `handler.py` file:

```
def handle(req):
    ...
    ...
    ...
    
```

Where you have to include the functionality of the function.


### Generic example function with Python

This is an example of code that detects faces with a pretrained classifier:

```
import cv2

# Load the cascade Classifier
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
# Read the input image
img = cv2.imread('test.jpg')
# Convert into grayscale
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# Detect faces
faces = face_cascade.detectMultiScale(gray, 1.1, 4)
# Draw rectangle around the faces
for (x, y, w, h) in faces:
    cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
# Display the output
cv2.imshow('img', img)
```

> **Remember that the result of the image composition must be sent to the user or saved in the service so that it can be downloaded or viewed.**


##  Delivery of practice

The delivery of the practice consists of 3 parts:

1. Development and description of the steps to set up the platform for the FaaS functions service, in one of the existing platforms (OpenFaas, OpenWhisk...).
2. Implementation of the face detection function in the selected language (python, node.js, etc.).
3. Steps for the deployment of the implemented function within the selected OpenFaaS platform.

All these steps must be documented in the delivery of the practice. For the delivery, all the material must be uploaded in a zip file to PRADO by the corresponding deadline. Subsequently, the day after the delivery, a Pull Request will be made to the repository of the subject to store the practice 2 as it was done in the first practice.

The zip file must contain the following:

- Platform deployment material
- Implemented function and its code
- Script to deploy the function on the chosen platform.

Deadline for submission: 16-May-2022 23:59:00


## References 

- FaaS Examples and Function deployment: https://github.com/openfaas/faas/tree/master/sample-functions

