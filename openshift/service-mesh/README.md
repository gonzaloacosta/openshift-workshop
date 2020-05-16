### Instalacion de Red Hat Service Mesh

Se deben instalar los siguientes operadores todos by Red Hat y no de la comunidad.

- Elasticsearch Operator
- Red Hat Openshift Jaeger
- Kiali Operator
- Red Hat Openshift Service Mesh

Los canales deben ser stable y la opcion de aprovacion debe ser automatic

```
oc get clusterserviceversion -n openshift-operators | grep 'Service Mesh'
```

Creamos el proyecto para alojar el operator de istio

```
oc adm new-project istio-system --display-name"Service Mesh Operator"
```

Creamos una nueva instalacion de istio

```
oc create -n istio-system -f service-mesh.yaml

```

Controlamos que los componentes sean desplegados

```
oc get smcp -n istio-system
```

Controlamos que los pods se vayan desplegando

```
oc get pods -n istio-system -w

```

Agregamos los proyectos mienbros del control plane de istio en el apartado ServiceMeshMemberRoll del archivo service-mesh.yaml

Una vez desplegado se puede modificar la configuracion asi

```
oc edit clusterserviceversion -n openshift-operators servicemeshoperator.v1.1.0
```

## Issue 1
Si usamos custom certificate, el pod de jaeger-proxy no inyecta la CA custom, por lo que hay que agregar el configMaps con el trusted-ca-bundle y mapearlo al deploymentconfig

```
oc create cm trusted-ca-bundle

oc label cm trusted-ca-bundle config.openshift.io/inject-trusted-cabundle=true

oc edit deploy grafana -n istio-system
oc edit deploy prometheus -n istio-system
oc edit deploy jaeger -n istio-system
...
      volumeMounts:

            - name: trusted-ca-bundle
              readOnly: true
              mountPath: /etc/pki/ca-trust/extracted/pem/
...
      volumeMounts:

        - name: trusted-ca-bundle
          configMap:
            name: trusted-ca-bundle
            items:
              - key: ca-bundle.crt
                path: tls-ca-bundle.pem
...
```

## Users
Agregamos rol de mesh-user a los administradores del service mesh. En el ejemplo el el control plane esta en istio-system y el usuario es gaacosat

oc policy add-role-to-user -n istio-system --role-namespace istio-system mesh-user gaacosta

Otra forma de asignar el mismo permiso pero via un template es la siguiente, creamos el archivo mesh-users.yaml

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: control-plane-namespace
  name: mesh-users
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: mesh-user
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: gaacosta
```

```
oc apply -f mesh-users.yaml
```

## Agregar o quitar un project de service mesh
Para elimiar un proyecto del mesh debemos ir al webconsole y borrarlo de la lista del ServiceMeshMemberRolls

desde la cli hacemos lo siguiente

```
oc edit smmr -n istio-system
...
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: istio-system
spec:
  members:
    - mask <--- borrar esta entrada
    - venom <--- solo queda este proyecto en el mesh
```

Para borrar un control plane

```
oc get servicemeshcontrolplanes -n istio-system
oc delete servicemeshcontrolplanes -n istio-system <name_of_custom_resource>
```

Una vez esta todo borrado hacer un clean de los objetos restantes

```
oc delete validatingwebhookconfiguration/<operator-project>.servicemesh-resources.maistra.io
oc delete mutatingwebhoookconfigurations/<operator-project>.servicemesh-resources.maistra.io
oc delete -n <operator-project> daemonset/istio-node
oc delete clusterrole/istio-admin clusterrole/istio-cni clusterrolebinding/istio-cni
oc get crds -o name | grep '.*\.istio\.io' | xargs -r -n 1 oc delete
oc get crds -o name | grep '.*\.maistra\.io' | xargs -r -n 1 oc delete
```

## Upgrade
Editar el yaml del control plane y subir la version

```
spec:
  version: v1.1
  ...
```

### Inject side car en un deployment
Para inyectar un sidecard en un deployment debemos agregar el label que se indica debajo sidecar.istio.io/inject: true

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sleep
spec:
  replicas: 1
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "true"
      labels:
        app: sleep
    spec:
      containers:
      - name: sleep
        image: tutum/curl
        command: ["/bin/sleep","infinity"]
        imagePullPolicy: IfNotPresent
```

### Clean de ElasticSearch para Jeager
En el operador hay que agregar estos valores

```
  apiVersion: jaegertracing.io/v1
  kind: Jaeger
  spec:
    strategy: production
    storage:
      type: elasticsearch
      esIndexCleaner:
        enabled: false
        numberOfDays: 7
        schedule: "55 23 * * *"
```

### Crear aplicacion ejemplo bookinfo

oc new-project bookinfo
oc -n istio-system patch --type='json' smmr default -p '[{"op": "add", "path": "/spec/members", "value":["'"bookinfo"'"]}]'
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/bookinfo/maistra-1.1/bookinfo.yaml
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/bookinfo/maistra-1.1/bookinfo-gateway.yaml
**

