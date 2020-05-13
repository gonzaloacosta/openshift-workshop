## Openshift - Manifest YAML

Los manifest YAML son declaraciones del estado deseado de los recursos que deseamos desplegar dentro del cluster de Openshift. De esta manera podemos crear cada uno de los recuros de manera declarativa. Si desearamos levantar una aplicacion de este modo, lo que haremos es generar los manifest en formato YAML o JSON y luego los crearemos de manera secuencial.

Tomando una aplicacion ejemplo, los pasos a seguir para poder crear cada uno de los recursos son los que siguen;

1. Creamos el namespaces.
```
oc create -f namespace.yaml
```
2. Creamos el servicio que expondra internamente nuestra aplicacion.
```
oc create -f service.yaml
```
3. Creamos la ruta que expondar nuestra aplicacion.
```
oc create -f route.yaml
```
4. Creamos el deploymentconfig que lanzara nuestra aplicacion, en este caso estamos utilizando en despliegue a partir de una imagen ya pre-contruida.
```
oc create -f deployment.yaml
```
5. Visualizamos que cada uno de los objetos haya sido creado.
```
oc get all
```
