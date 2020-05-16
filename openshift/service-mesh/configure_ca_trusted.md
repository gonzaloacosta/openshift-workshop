#### Service Mesh - Configuracion de una Custom CA Trusted

La configuracion se debe hacer en base a un bug detectado por Red Hat donde el operador del control plance no despliega la CA Custom dada de alta en el proyecto openshift-config recurso proxy ```oc get proxy -n openshift-config```

Red Hat Docs: https://access.redhat.com/solutions/4896741

- Nos paramos en el proyecto del control plane de istio
```bash
oc project istio-system
``` 

- Configuracion del configMaps**

```bash
$ oc create configmap trusted-ca-bundle -n istio-system
$ oc label configmap/trusted-ca-bundle -n istio-system "config.openshift.io/inject-trusted-cabundle=true" 
```

- Patch de Prometheus
```bash
$ oc patch deployment/prometheus -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"prometheus-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"prometheus","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
```

- Patch de Grafana  
```bash
$ oc patch deployment/grafana -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"grafana-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"grafana","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
```

- Pach Jaeger
```bash
$ oc patch deployment/jaeger -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"oauth-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"jaeger","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
```

- Redeploy de los pods para que tome las CA.
```bash
$  oc scale --replicas 0 -n openshift-operators deployment/istio-operator
deployment.extensions/istio-operator scaled
$ oc scale --replicas 0 -n openshift-operators deployment/jaeger-operator
deployment.extensions/jaeger-operator scaled
```

#### Diagnostico

- Login fail con error 500.
- Chech de proxy
```bash
oc get proxy -o yaml -n openshift-config
```

```
$ oc logs -n istio-system grafana-76d6c94b9f-2trwh -c grafana-proxy
2020/03/11 11:36:36 oauthproxy.go:645: error redeeming code (client:10.128.2.26:59268): Post https://oauth-openshift.apps.cluster.domain.tld/oauth/token: x509: certificate signed by unknown authority
2020/03/11 11:36:36 oauthproxy.go:438: ErrorPage 500 Internal Error Internal Error

$ oc logs -n istio-system prometheus-c7d8d58d4-8fl8k -c prometheus-proxy
2020/03/11 11:39:11 oauthproxy.go:645: error redeeming code (client:10.128.2.26:32938): Post https://oauth-openshift.apps.cluster.domain.tld/oauth/token: x509: certificate signed by unknown authority
2020/03/11 11:39:11 oauthproxy.go:438: ErrorPage 500 Internal Error Internal Error

$ oc logs jaeger-b95c8f846-8t2qt -c oauth-proxy
2020/03/11 11:40:45 oauthproxy.go:645: error redeeming code (client:10.128.2.26:50712): Post https://oauth-openshift.apps.cluster.domain.tld/oauth/token: x509: certificate signed by unknown authority
2020/03/11 11:40:45 oauthproxy.go:438: ErrorPage 500 Internal Error Internal Error
```
