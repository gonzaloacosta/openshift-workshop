## Kubernetes - Manifest YAML

Los manifest YAML (o JSON) son definiciones del estado deseado de los recursos que utilizara la aplicacion para poder funcionar dentro del cluster de Kubernetes.

Para poder desplegar una aplicacion vamos a generar cada uno de los archivos con la definicion del como queremos que sean creados y ejecutados.

Para crear una aplicacion realizaremos lo siguiente.

0. Nos paramos en el directorio de trabajo deployments.
```
cd deployments/
```
1. Creamos el namespaces.
```
kubectl apply -f namespace.yaml
```
2. Creamos el servicio que expondra internamente nuestra aplicacion.
```
kubectl apply -f service.yaml
```
3. Crearemos los secretos que seran declarados como variables de entorno.
```
kubectl apply -f secrets.yaml
```
5. Crearemos el deployment que lanzara los pods con nuestra aplicacion basada en una imagen pre existente.
```
kubectl apply -f deployment.yaml
```
6. Chequemos el estado de los recuros.
```
kubectl get all
```

En el caso que quisieramos hacer todos los pasos implementados en un solo deploy, lo podriamos agrupar en un mismo archivo donde de manera secuencial y separados por los --- del archivo YAML declaramos cada uno de los objetos que repasamos anteriormente.

```
kubectl apply -f deploy.yaml
```