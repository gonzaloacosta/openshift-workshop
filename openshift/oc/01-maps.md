## Openshift - Management Deployment

Temas a ver en este apartado:

- BuildConfig
- DeploymentConfig
- Service
- Routes
- ConfigMaps
- Secrets

Deploy usando new-app
```
oc new-app --name=dc-metro-map https://github.com/RedHatGov/openshift-workshops.git --context-dir=dc-metro-map
```
Exponemos aplicacion
```
oc expose service dc-metro-map
```
Chequemos el build
```
oc get builds
```
Verificamos los logs del build
```
oc logs builds/[build-name]
```
Verificamos la rutas
```
oc get routes
```
Verificando app desplegada
```
oc status
```
Verificamos el deploymentconfig
```
oc describe deploymentconfig/dc-metro-map
```
Verificamos el replication controller
```
oc describe rc -l app=dc-metro-map
```
Verificamos el imagestreams
```
oc describe is -l app=dc-metro-map
```
Verificamos el pods
```
oc describe pod
```
Verificamos el build
```
oc describe build/dc-metro-map-1
```
Verificamos logs de aplicacion
```
oc logs [pod name]
```
Cambiamos variables de entorno
```
oc set env deploymentconfig/dc-metro-map -e BEERME=true
```
Vemos los nuevos despliegues 
```
oc get pods -w
```
Ejecutamos un comando dentro del pod
```
oc exec -it [POD NAME] /bin/bash
$ env | grep BEER
$ exit
```
Eliminamos todos los pods
```
oc delete all -l app=dc-metro-map
oc delete secrets dc-metro-map-generic-webhook-secret dc-metro-map-github-webhook-secret    
```
Aumentar las replicas
```
oc scale --replicas=4 deployment/dc-metro-map 
```
Verifico pods y tomo nota de un nombre
```
oc get pods 
```
Elimino un pod
```
oc delete pod [pod name]
```
Verifico como se recuperan las replicas 
```
oc get pods
```
Verifico el estado deseado en deployment 
```
oc describe deploymentconfig/dc-metro-map
```

