#!/bin/bash

kubectl delete crd meshes.appmesh.k8s.aws

kubectl delete crd virtualnodes.appmesh.k8s.aws

kubectl delete crd virtualservices.appmesh.k8s.aws


helm delete appmesh-controller --namespace appmesh-system

helm delete appmesh-inject --namespace appmesh-system

kubectl label namespace api-test-ns appmesh.k8s.aws/sidecarInjectorWebhook=disabled --overwrite=true

kubectl delete  -f api-test-front.yaml

kubectl delete  -f ../code2statebck/api-test-back.yaml

kubectl delete  -f ../code2statebckv1/api-test-back.yaml

kubectl delete  -f services.yaml 

kubectl delete  -f ../code2statebckv1/services_canary.yaml
 
kubectl delete  -f ingress.yaml 

kubectl delete -f virtualnodes_canary.yaml

kubectl delete -f virtualservices_canary.yaml 

kubectl delete -f namespace.yaml

kubectl get all -napi-test-ns


