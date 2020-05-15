## Openshift Ingress Controller (POD Router) ##

**Escenario**

Con el fin de poder desacoplar trafico de ingress para las aplicaciones aplicativas en un cluster de openshift podemos definir multiples ingress controller.

Supongamos que tenemos una red de DMZ con un direccionamiento ```10.0.0.0/24``` y una red local con un direccionamiento ```20.0.0.0/24```. Tanto los nodos como los namespaces que vivan en la Red de DMZ tendran el label ```network-zone=dmz``` y los namespaces y los nodos que esten en la red local tendran el label ```network-zone=local```.

De esta manera vamos a poder desplegar ingress controller (nuevos pod router) dedicados para cada zona y los pods router filtren trafico por label aplicado. Por ejemplo

Vamos a tener dos ingress controller

* **default** > atiende los namespaces con label ```network-zone=local``` > wildcard: ocp.dmz.dominio.com
* **dmz** > atiende los namespaces con label ```network-zone=dmz``` > wildcard default: apps.ocp.dominio.com

NOTA: los pod router pueden filtraf tanto por nombre de namespaces como por labels colocadas en rutas, para mas detalle consultar la ayuda en la declaracion del Operador Ingress Controller.

**Agregarle selector al IngressController default**
Debemos agregar el selector de namespaces al despliegue default, el original que atiende el wildcard default, pod router default.

Taggeamos todos los namespaces de infraestructura (openshift-*) que exponen rutas via el ingress controller **default**. Le agregamos el label network-zone=local a los namespaces como al ingress-controller.

```
oc label namespace openshift-authentication network-zone=local
oc label namespace openshift-console network-zone=local
oc label namespace openshift-logging network-zone=local
oc label namespace openshift-monitoring network-zone=local
oc label namespace openshift-image-registry network-zone=local
```

**Agregamos al ingress default el tag network-zone=rc**
```
oc edit --namespace=openshift-ingress-operator ingresscontroller/default
...
spec
  namespaceSelector:
    matchLabels:
      network-zone: local
...
```

Una vez que chequeamos que todo funciona correctamente con las rutas originales, las que ya estaban creadas, creamos el nuevo IngressController para la red DMZ.

**Pasos para crear el ingress controller de DMZ**

Crear la definicion del nuevo ingress controller, como se puede ver tenemos el ```matchLabel: network-zone: dmz``` y el ```nodeSelector: matchLabel: node-role.kubernetes.io/infra: dmz``` de manera que se posicione el pod router sobre el nodo de infraestructura etiquetado como infra: dmz.

```
cat << EOF > router-network-zone-dmz.yaml
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: network-zone-dmz
  namespace: openshift-ingress-operator
spec:
  domain: apps.dmz.dominio.com
  namespaceSelector:
    matchLabels:
      network-zone: dmz
  nodePlacement:
    nodeSelector:
      matchLabels:
        node-role.kubernetes.io/infra: dmz
  replicas: 3
EOF
```

Cremos el recurso ingress controller
```
oc create -f ingress-rs.yaml
```

Chequeamos que se haya creado y en los nodos qeu deseamos se hayan colocado.
```
oc get pods -o wide -n openshift-ingress
```

** Creado de rutas **
Cuando creamos un proyecto que va a estar alojado en la red de DMZ lo reamos de la siguiente manera. Supongamos que esta en la red de DMZ y es de PROD.
```
oc new-project myapps-front-prod --display-name="Proyecto en la red DMZ PROD"
oc label namespaces myapps-front-prod network-zone=dmz
oc label namespaces myapps-front-prod environment=prod
```

En caso de que el backend este en la red local lo creamos de la siguiente manera
```
oc new-project myapps-back-prod --display-name="Proyecto Back en la red Local PROD"
oc label namespaces myapps-front-prod network-zone=local
oc label namespaces myapps-front-prod environment=prod
```

Una vez dentro de cada apliacacion podemos desplegar una app ejemplo.
```
oc new-app openshiftkatacoda/blog-django-py --name blog -n myapps-front-prod 
oc new-app openshiftkatacoda/blog-django-py --name blog -n myapps-back-prod 
oc set env dc/blog BLOG_BANNER_COLOR=green -n myapps-back-prod
```

Para poder exponer una aplicacion en la red de dmz lo realizamos de la siguiente manera, se puede ver que indicamos el servicio y la url que queremos exponer.
```
oc create route edge blog --service=blog --hostname=blog.apps.dmz.dominio.com -n myapps-front-prod
```

Para el caso de la red de back, sin especificar el parametro --hostname la ruta se genera dinamicamente en base al wildcard por defecto. 
```
oc create route edge blog --service=blog -n myapps-front-prod
```