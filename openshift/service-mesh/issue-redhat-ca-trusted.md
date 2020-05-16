## Issue 1

Si usamos custom certificate, el pod de jaeger-proxy no inyecta la CA custom, por lo que hay que agregar el configMaps con el trusted-ca-bundle y mapearlo al deploymentconfig

1. Creamos el ConfigMaps

```bash
oc create cm trusted-ca-bundle
```

2. Agregamos el label para que openshift inyecte la CA al ConfigMaps.
```bash
oc label cm trusted-ca-bundle config.openshift.io/inject-trusted-cabundle=true
```

3. Editamos los deployments de grafana, prometheus, jaeger y modificamos el volumeMount del contenedor de oauth-proxy y el volume.

```
oc edit deploy jaeger -n istio-system
...
      volumeMounts:
...
            - name: trusted-ca-bundle
              readOnly: true
              mountPath: /etc/pki/ca-trust/extracted/pem/
...
      volumeMounts:

        - name: trusted-ca-bundle
          configMap:
            name: trusted-ca-bundle
            items:
              - key: ca-bundle.crt
                path: tls-ca-bundle.pem
...
```

Seguir con el mismo procedimiento para los dos deployments.
```bash
oc edit deploy grafana -n istio-system
oc edit deploy prometheus -n istio-system
```

En caso de querer hacerlo con patch podemos seguir el caso de Red Hat del siguiente link.
```https://access.redhat.com/solutions/4896741```
