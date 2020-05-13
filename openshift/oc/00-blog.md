## Openshift - Despliegue de aplicaciones

En la siguiente seccion desplegaremos aplicaciones desde la CLI de Openshift con el comando oc.

Los objetos que seran repasados son los siguientes:

- Namespaces
- BuildConfig
- DeploymentConfig
   - Image
   - Source code
   - Dockerfile
   - Database
- Service
- Routes
- ConfigMaps
- Secrets
- Volumes

Creamos el proyecto **workshop**
```
oc new-project workshop --display-name "Workshop Arquitectura"
```
**ATENCION:**: En el caso de contar con un cluster con network-zones colocar los labels correcto al proyecto.
```
oc label namespace workshop network-zones=rc
oc label namespace workshop name=workshop
oc label namespace workshop environment=desa
```

Despliegamos la aplicacion ejemplo desde un imagen previamente contruida.
```
oc new-app openshiftkatacoda/blog-django-py --name blog 
oc expose service/blog
```
Revisamos todo lo desplegado
```
 oc get all -o name --selector app=blog 
```

Aumentamos el numero de replicas
```
oc scale --replicas=3 dc/blog 
```

Seteamos las variables de entorno
```
oc set env dc/blog BLOG_BANNER_COLOR=green 
```

Listamos las variables de entorno
```
oc set env dc/blog --list
```
Borrar todo el blog
```
oc delete all --selector app=blog 
```

## Distintos tipos de despliegues
- Despliegue desde una imagen
```
oc new-app openshiftkatacoda/blog-django-py --name blog-from-image
oc expose svc/blog-from-image
```

- Despliegue desde codigo fuente
```
oc new-app python:latest~https://github.com/openshift-katacoda/blog-django-py --name blog-from-source-py
oc expose svc/blog-from-source-py
```

- Despliegue desde codigo fuente cuando hay un dockerfile en repositorio
```
oc new-app --strategy=source https://github.com/openshift-katacoda/blog-django-py --name blog-from-source-auto
oc expose svc/blog-from-source-auto
```

- Desplieuge desde dockerfile
```
oc new-app https://github.com/openshift-katacoda/blog-django-py --name blog-from-docker
oc expose svc/blog-from-docker
```

- Agregamos una base de datos postgres
```
oc new-app postgresql-persistent --name blog-database --param DATABASE_SERVICE_NAME=blog-database --param POSTGRESQL_USER=sampledb --param POSTGRESQL_PASSWORD=sampledb --param POSTGRESQL_DATABASE=sampledb
```

Seteamos la variable de entorno de la base de datos al deploymentconfig/blog
```
oc set env dc/blog-from-source-py DATABASE_URL=postgresql://sampledb:sampledb@blog-database:5432/sampledb
```

Configuracion de la base desde el pod de blog
```
POD=`oc get pods --selector app=blog-from-source-py -o name`
oc rsh $POD scripts/setup
```

- Cambiamos el modo de deploy de Rolling a Recreate
```
oc patch dc/blog-from-source-py -p '{"spec":{"strategy":{"type":"Recreate"}}}'
```

Agregamos un volumen persistente al dc/blog
```
oc set volume dc/blog-from-source-py --add --name=blog-images -t pvc --claim-size=1G -m /opt/app-root/src/media
```

- Seteo de variables de entorno
```
oc set env dc/blog-from-source-py BLOG_BANNER_COLOR=blue
```
- Creamos el archivo que usaremos como configmap
```
cat << EOF >> blog.json
{
   "BLOG_SITE_NAME": "OpenShift Blog",
   "BLOG_BANNER_COLOR": "black"
}
EOF
```
Creamos el configmap
```
oc create configmap blog-settings --from-file=blog.json
```
Seteamos el volumen para el configmaps
````
oc set volume dc/blog --add --name settings --mount-path /opt/app-root/src/settings --configmap-name blog-settings -t configmap
```

Agregamos liveness y rediness probes
```
oc set probe dc/blog --readiness --get-url=http://:8080/ --initial-delay-seconds=2
oc set probe dc/blog --liveness --get-url=http://:8080/ --initial-delay-seconds=2
```
