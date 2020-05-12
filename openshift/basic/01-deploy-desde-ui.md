# Desplegar una aplicacion desde la UI

# Image
quay.io/openshifthomeroom/workshop-terminal

# Verificamos la apliacion desplegada desde la consola

# Login
oc login -u user1 https://api.ocp4.labs.semperti.local:6443

# Verificamos los proyectos asignados
oc get project

# Creamos un nuevo proyecto
oc new-project workshop

# Verificamos estado de objectos dentro del proyecto
oc status

