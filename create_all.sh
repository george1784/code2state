#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/appmesh-controller/crds/crds.yaml
helm upgrade -i appmesh-controller eks/appmesh-controller --namespace appmesh-system
helm upgrade -i appmesh-inject eks/appmesh-inject --namespace appmesh-system --set mesh.create=true --set mesh.name=global
helm upgrade -i appmesh-inject eks/appmesh-inject --namespace appmesh-system --set tracing.enabled=true --set tracing.provider=x-ray

kubectl apply -f namespace.yaml

kubectl label namespace api-test-ns appmesh.k8s.aws/sidecarInjectorWebhook=enabled --overwrite=true

kubectl apply -f virtualnodes.yaml

kubectl apply -f virtualservices.yaml 



kubectl apply  -f api-test-front.yaml

kubectl apply  -f ../code2statebck/api-test-back.yaml

kubectl apply  -f services.yaml 
 
kubectl apply  -f ingress.yaml 

echo 'creating ELB'

sleep 20

kubectl get all -napi-test-ns