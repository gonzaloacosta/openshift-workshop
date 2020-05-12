# Verificando app desplegada
oc status

# Verificamos el deploymentconfig
oc describe deploymentconfig/dc-metro-map

# Verificamos el replication controller
oc describe rc -l app=dc-metro-map

# Verificamos el imagestreams
oc describe is -l app=dc-metro-map

# Verificamos el pods
oc describe pod

# Verificamos el build
oc describe build/dc-metro-map-1

# Verificamos logs de aplicacion
oc logs [pod name]

# Cambiamos variables de entorno
oc set env deploymentconfig/dc-metro-map -e BEERME=true

# Vemos los nuevos despliegues 
oc get pods -w

# Ejecutamos un comando dentro del pod
oc exec -it [POD NAME] /bin/bash
$ env | grep BEER
$ exit

# Eliminamos todos los pods
oc delete all -l app=dc-metro-map
oc delete secrets dc-metro-map-generic-webhook-secret dc-metro-map-github-webhook-secret    

