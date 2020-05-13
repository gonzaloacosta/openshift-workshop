## Podman - Ejercicios practicos

Instalar containers tools
```
yum -y install buildah skopeo podman
```
Pull de imagenes
```
podman pull registry.access.redhat.com/rhel7
```
Inspeccionar imagen
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

