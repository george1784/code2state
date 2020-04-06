#!/bin/bash


kubectl apply -f namespace.yaml

kubectl label namespace api-test-ns appmesh.k8s.aws/sidecarInjectorWebhook=disabled --overwrite=true

kubectl apply  -f api-test-front.yaml

kubectl apply  -f ../code2statebck/api-test-back.yaml

kubectl apply  -f services.yaml 
 
kubectl apply  -f ingress.yaml 

kubectl get all -napi-test-ns