# Deploy de una imagen desde el repositorio de codigo

# Deploy usando new-app
oc new-app --name=dc-metro-map https://github.com/RedHatGov/openshift-workshops.git --context-dir=dc-metro-map

# Exponemos aplicacion
oc expose service dc-metro-map

# Chequemos el build
oc get builds

# Verificamos los logs del build
oc logs builds/[build-name]

# Verificamos la rutas
oc get routes

