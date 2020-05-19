#!/bin/bash

# 
# Based in RH Note: https://access.redhat.com/solutions/4896741
#
echo" Create a ConfigMaps in istio-system will be filled with CA bundle"
oc create configmap trusted-ca-bundle -n istio-system
oc label configmap/trusted-ca-bundle -n istio-system "config.openshift.io/inject-trusted-cabundle=true"
echo ""

echo "Edit Prometheus deployment to mount ConfigMaps"
oc patch deployment/prometheus -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"prometheus-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"prometheus","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
echo ""

echo "Edit Grafana deployment to mount ConfigMaps"
oc patch deployment/grafana -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"grafana-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"grafana","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
echo ""

echo "Edit Jaeger deployment to mount ConfigMaps"
oc patch deployment/jaeger -n istio-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"oauth-proxy","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]},{"name":"jaeger","volumeMounts":[{"mountPath":"/etc/pki/ca-trust/extracted/pem/","name":"trusted-ca-bundle","readOnly":true}]}],"volumes":[{"configMap":{"defaultMode":420,"items":[{"key":"ca-bundle.crt","path":"tls-ca-bundle.pem"}],"name":"trusted-ca-bundle","optional":true},"name":"trusted-ca-bundle"}]}}}}'
echo ""

echo "Scale down two of the operators which will delete the previus changes"
oc scale --replicas 0 -n openshift-operators deployment/istio-operator
oc scale --replicas 0 -n openshift-operators deployment/jaeger-operator

