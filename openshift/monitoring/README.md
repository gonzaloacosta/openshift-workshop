## Metrics Hand On

## Prometheus
Agregar nuevo stack de metricas para pode monitorear apps.

1. Deploy de una aplicacion que tenga el modulo de metricas consultado via /metrics

Deploy de aplicacion /openshift/manifest/metrics-demo/deploy-metrics-apps.yaml

2. Deploy de Prometheus

Puede ser via Operators o via deploy con imagen, para un deploy con imagen un ejemplo abajo

openshift/monitoring/prometheus/template-prometheus.yaml

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
