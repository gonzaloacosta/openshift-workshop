## Kubernetes Labels

Los labels son utilizados para ordenar los deployments de pods

Verificamos los pods
```
oc get pods 
```

Verificamos los labels
```
oc get posd --show-labels
```
Etiquetamos un pods
```
oc label pod/[pod name] eliminar=true 
```


