# Como crear una registry local

1. Instalamos paquetes
yum -y install docker-distribution

2. Habilitamos servicio
systemct enable docker-distribution

3. Habilitamos https

Creamos los certificados
```
mkdir /etc/docker-distribution/certs
cd /etc/docker-distribution/certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt
cp domain.crt /etc/pki/tls/certs
update-ca-trust extract
```

Modificamos los archivos de configuracion
```
vi /etc/docker-distribution/registry/config.yml
version: 0.1
log:
  fields:
    service: registry
storage:
    cache:
        layerinfo: inmemory
    filesystem:
        rootdirectory: /var/lib/registry
    delete:
        enabled: true
http:
    addr: :5000
    tls:
      certificate: /etc/docker-distribution/certs/domain.crt
      key: /etc/docker-distribution/certs/domain.key
    host: https://localhost:5000
    relativeurls: false
```

3. Levantamos servicios
systemctl start docker-distribution

4. Verificamos imagenes
podman images

5. Realizamos un pull de una imagen local a la registry local
buildah push fedora_postgresql:latest localhost:5000/fedora_postgresql:latest

6. Realizamos el pull de la imagen pero con skopeo
skopeo copy containers-storage:7a840db7f020 docker://localhost:5000/fedora_postgresql:latest

7. Search de la imagen con podman 
podman search localhost:5000/postgresl
