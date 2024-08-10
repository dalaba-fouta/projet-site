# Projet: Site Web Statique 

## Objectif

Ce projet a pour but de créer une image Docker pour un site web statique en utilisant Nginx, de déployer cette image sur Kubernetes, et d'automatiser le déploiement via GitHub et Docker Hub.

## Sommaire

1. [Structure du Projet](#structure-du-projet)
2. [Installation et Déploiement](#installation-et-déploiement)
   - [Dockerfile](#dockerfile)
   - [Configuration Nginx](#configuration-nginx-nginxconf)
   - [Configuration du Déploiement Kubernetes](#configuration-du-déploiement-kubernetes-deplymentyaml)
   - [Configuration du Service Kubernetes](#configuration-du-service-kubernetes-serviceyaml)
3. [Déploiement et Intégration Continue](#déploiement-et-intégration-continue)

## 1. Structure du Projet

- `html/` : Contient les fichiers HTML, CSS, et images du site.
- `nginx.conf` : Fichier de configuration pour Nginx.
- `dockerfile` : Dockerfile pour construire l'image Docker.
- `service.yaml` : Configuration du service Kubernetes.
- `deplyment.yaml` : Configuration du déploiement Kubernetes.

## 2. Installation et Déploiement

### Dockerfile

FROM nginx
RUN rm -r /usr/share/nginx/html
COPY html /usr/share/nginx/
COPY nginx.conf /etc/nginx/nginx.conf

### Configuration Nginx (nginx.conf):
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        server_name  localhost;

        root   /usr/share/nginx/html;
        index  index.html index.htm;

        location / {
            try_files $uri $uri/ =404;
        }

        error_page  500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}

### Configuration du Déploiement Kubernetes (deplyment.yaml):

apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploiement-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx-container
          image: dddiallo/site
          ports:
            - containerPort: 80

### Configuration du Service Kubernetes (service.yaml)

apiVersion: v1
kind: Service
metadata:
  name: service-site
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 31000
  type: NodePort

