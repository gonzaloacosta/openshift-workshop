## Containers - Hands On 

En el repositorio encontraran documentacion de como hacer uso de las siguietnes herramientas para adminsitrar contenedores de manera local como remota.

1. Podman
2. Buildah
3. Skopeo
4. Dockerfiles
5. Docker Registry


Instalar containers tools
```
yum -y install buildah skopeo podman
```

Pull de imagenes
```
podman pull docker://registry.access.redhat.com/rhel7
```

ionar imagen
```
skopeo inspect docker://registry.access.redhat.com/rhel7
```
Visualizar imagen descargada
```
podman images
```
Informacion de servicio
```
podman info
```
Run Container
```
podman run --rm -it registry.access.redhat.com/rhel7 /bin/bash
```
Correr los comandos dentro del contenedor
```
ls
whoami 
uname -a 
exit
```
Networking del contenedor
```
podman run --rm -it rhel7 /usr/sbin/ip a
```
Mapeo de volumenes en un contenedor
```
podman run -v /usr/sbin:/usr/sbin --rm -it rhel7 /usr/sbin/ip a
```
Mapeo de volumenes en un contenedor
```
podman run -v /dev/log:/dev/log --rm rhel7 logger Testing logging to the host
```
Persistent Container Data
```
mkdir /opt/rhel_data

podman run -d -p 8080:8000 --name="python_web" \
       -w /opt \
       -v /opt/rhel_data:/opt rhel7 \
       /bin/python -m SimpleHTTPServer 8000
```

Verificar que el comando este corriendo usando podman 
```
podman ps 
```
Verificamos directorio local
```
ll /opt/rhel_data/
```
Testeamos servicio en port local
```
curl localhost:8080
```
Creamos archivos
```
for i in {1..10}; do touch /opt/rhel_data/file${i}; done
ll /opt/rhel_data/
```
Chequemos servicio web
```
curl localhost:8080
```
Inspeccionamos contenedor
```
podman inspect python_web
```
Inspeccionamos el contenedor para sacar la ip
```
podman inspect -f {{.NetworkSettings.IPAddress}} python_web
```
Abrimos terminal en el contenedor
```
podman run --rm -it rhel7 bash
```
Verificamos el cgroups para el contendor
```
cat /proc/1/cgroup
```
Verificamos los cgroups en la maquina de trabajo
```
cat /proc/1/cgroup
```
## Dockerfiles
Directorio de trabajo ./build y dentro Dockerfile

Verificamos que el Dockerfile este dentro del directorio de trabajo
```
cat build/Dockerfile
FROM docker.io/library/fedora:latest
RUN yum install -y postgresql-server
USER postgres
RUN /bin/initdb -D /var/lib/pgsql/data
RUN /usr/bin/pg_ctl start -D /var/lib/pgsql/data -s -o "-p 5432" -w -t 300 &&\
                /bin/psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
                /bin/createdb -O docker docker
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf
EXPOSE 5432
CMD ["/bin/postgres", "-D", "/var/lib/pgsql/data", "-c", "config_file=/var/lib/pgsql/data/postgresql.conf"]
```

Realizamos el build de Dockerfile
```
buildah bud -t fedora_postgresql .
```

Corremos el contenedor
```
podman run -d --name fpg fedora_postgresql
```
Corremos comando dentro del contenedor
```
podman exec -t fpg psgl
..
\l
\q
```

## Crear una docker-registry

### Docker Registry 
Como crear una registry local

1. Instalamos paquetes
```
yum -y install docker-distribution
```
2. Habilitamos servicio
```
systemct enable docker-distribution
```
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
```
systemctl start docker-distribution
```
4. Verificamos imagenes
```
podman images
```
5. Realizamos un pull de una imagen local a la registry local
```
buildah push fedora_postgresql:latest localhost:5000/fedora_postgresql:latest
```
6. Realizamos el pull de la imagen pero con skopeo
```
skopeo copy containers-storage:7a840db7f020 docker://localhost:5000/fedora_postgresql:latest
```
7. Search de la imagen con podman 
```
podman search localhost:5000/postgresl
```