#!/bin/bash

kubectl delete crd meshes.appmesh.k8s.aws

kubectl delete crd virtualnodes.appmesh.k8s.aws

kubectl delete crd virtualservices.appmesh.k8s.aws

helm delete appmesh-inject eks/appmesh-inject

helm delete appmesh-controller eks/appmesh-controller

kubectl label namespace api-test-ns appmesh.k8s.aws/sidecarInjectorWebhook=disabled --overwrite=true

kubectl delete  -f api-test-front.yaml

kubectl delete  -f ../code2statebck/api-test-back.yaml

kubectl delete  -f services.yaml 
 
kubectl delete  -f ingress.yaml 

kubectl delete -f virtualnodes.yaml

kubectl delete -f virtualservices.yaml 

kubectl delete -f namespace.yaml

kubectl get all -napi-test-ns


