import cv2
import requests
import numpy as np
from flask import Flask, request, Response, send_file
from tempfile import NamedTemporaryFile
from urllib.request import urlopen

def url_to_image(url, readFlag=cv2.IMREAD_COLOR):
    resp = urlopen(url)
    image = np.asarray(bytearray(resp.read()), dtype="uint8")
    image = cv2.imdecode(image, readFlag)

    return image

def draw_faces(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Detectar caras
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

    faces = face_cascade.detectMultiScale(
        gray
    )
    # Elipse alrededor de las caras
    for (x, y, w, h) in faces:
        center = (x + w//2, y + h//2)
        img = cv2.ellipse(img, center, (w//2, h//2), 0, 0, 360, (255, 0, 255), 4)

    return img

def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """
    image = url_to_image(req)
    img = draw_faces(image)
    with NamedTemporaryFile() as tmp:
        iName = "".join([str(tmp.name),".jpg"])
        cv2.imwrite(iName,image)
        return send_file(iName, mimetype='image/jpg')