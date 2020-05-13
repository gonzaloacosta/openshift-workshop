## Openshift - Templates

Los templates en Openshift son utilizados para desplegar multiples recursos de modo de preparar bundles de aplicaciones a desplegar de una sola vez. Estos tambien son utilizados para armar nuevas opciones que damos de alta en el catalogo de aplicaciones en la vista de Developer.

El repositorio tiene un archivo declarativo con el despliegue completo de una aplicacion para poder darlo de alta en su cluster de Openshift debe ejecutar los siguiente.

```
oc create -f template.yaml -n openshift
```

Es ejecutado en el proyecto openshift porque en ahi donde alojamos de manera centralizada cada uno de los templates aplicativos que seran disponibles para cada uno de los desarrolladores que trabajen en el cluster. En caso que se desee limitar la visibilidad aplicativa a solo un proyecto lo haremos indicando el proyecto destino.

```
oc create -f template.yaml -n <project_name>
```

