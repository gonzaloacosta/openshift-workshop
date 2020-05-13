## Metrics Custom - Hand On



Agregar nuevo stack de metricas para pode monitorear aplicaciones. Las aplicaciones deben estar preparadas de manera que en alguna url expongan el path /metrics

## Aplicacion ejemplo

Deploy de una aplicacion que tenga el modulo de metricas consultado via /metrics. En este caso vamos a desplegar una aplicacion llamando a una imagen pre configurada. El manifiesto de deploy se encuentra en el siguiente path ```openshift/manifest/metrics-demo/deploy-metrics-apps.yaml``` de este mismo repositorio.

Podemos ejecutar el deploy de la siguiente manera.
```
oc create -f openshift/deployments/manifest/metrics-demo/deploy-metrics-apps.yaml
```

## Prometheus

Podemos desplegar prometheus desde OperatorHUB o via deploy desde la linea de comandos llamando a la imagen en un repositorio publico. 

El path donde esta el template de deploy de prometheus es el siguiente ```openshift/monitoring/prometheus/template-prometheus.yaml```

Ejecutamos el deploy via cliente oc.

```
oc process -f template-prometheus.yaml | oc apply -f -
```

Una vez arriba podemos ver la ruta de exposicion del servicio
```
oc get routes
```

Accedemos a la UI
```
curl https://<prometheus route>/
```

Para el scrap de metricas de una aplicacion en targets especificamos la url y por defecto busca el path /metrics

```
cat < EOF > prometheus-configmaps.yaml
apiVersion: template.openshift.io/v1
kind: Template
objects:
  - apiVersion: v1          
    kind: ConfigMap
    metadata:
      name: prometheus-demo
      namespace: pad-monitoring
    data:     
      prometheus.yml: |
        global:                   
          external_labels:
            monitor: prometheus
        scrape_configs:
          - job_name: 'prometheus'

            static_configs:
              - targets: ['localhost:9090']
                labels:
                  group: 'prometheus'
              - targets: ['metrics-demo-app-metrics-demo.2886795274-80-host20nc.environments.katacoda.com'] 
                labels:
                  group: 'pad' 
EOF
```

Para poder agregar la configuracion de los targets agregamos un configmaps al deploy de prometheus quien levanta la configuracion.
```
oc process -f prometheus-configmap.yaml | oc apply -f -
```

Hacemos el rollout del deployment
```
oc rollout latest dc/prometheus -n monitoring
```

Chequeamos que los targets esten configurados.
```
curl https://<prometheus route>/targets
```

## Grafana
Hacemos el deploy de grafana
```
oc new-app grafana/grafana:6.6.1 -n monitoring
```

Exponemos grafana
```
oc expose svc/grafana -n pad-monitoring
```

Luego configuramos las credenciales para el usuario admin, incialmente colocar admin/admin y luego cambiar la password.

El paso siguiente es configurar el conector contra prometheus (datasource). Elegimos Prometheus y pegamos la url que expone prometheus, en caso de que sea openshift, podemos configurar la url de servicio sin exposicion publica.

## Dashboard de Grafana

Si desplegamos la aplicacion ejemplo podemos ejecutar estos dos dashboard PromQL

```
rate(flask_http_request_total[2m])
flask_http_request_total
```
