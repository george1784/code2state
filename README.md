# Full EKS Example


Spring boot example that emulates an adapter to backend service. Credits to https://phantomgrin.github.io/


This example allows you to install a dockerized Spring boot example on EKS (fully automated by Terraform), AWS Service Mesh,
X-Ray, Prometheus / Graphana  


Install Java editor with maven support, in my case Eclipse.
Install docker 
Install aws cli
Install kubectl and point to AWS instance (https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
Install helm (for MAC: brew install kubernetes-helm)
Install terraform 

-- Inside Terraform/eks
-

terraform init
terraform apply


-- CDR, aws mesh and side car injectors creation
-

helm repo add eks https://aws.github.io/eks-charts
kubectl create ns appmesh-system
kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/appmesh-controller/crds/crds.yaml
helm upgrade -i appmesh-controller eks/appmesh-controller --namespace appmesh-system
helm upgrade -i appmesh-inject eks/appmesh-inject --namespace appmesh-system --set mesh.create=true --set mesh.name=global

-- X-ray tracing
-

helm upgrade -i appmesh-inject eks/appmesh-inject --namespace appmesh-system --set tracing.enabled=true --set tracing.provider=x-ray

kubectl create -f https://eksworkshop.com/x-ray/daemonset.files/xray-k8s-daemonset.yaml

--test

kubectl describe daemonset xray-daemon


-- Install ALB ingress controller to generate automatic ALB with ingress deployment 
-

curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.6/docs/examples/alb-ingress-controller.yaml" \
     | sed "s/# - --cluster-name=devCluster/- --cluster-name=terraform-eks-demo/g" \
     | kubectl apply -f -


-- Install fluentd for logging 
-

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

kubectl create configmap cluster-info --from-literal=cluster.name=terraform-eks-demo --from-literal=logs.region=us-east-1 -n amazon-cloudwatch

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluentd/fluentd.yaml

--test

kubectl get all -n amazon-cloudwatch

--Docker creation 
-
mvn clean -Denv.DOCKER_IMAGE=api-test-front install
mvn clean -Denv.DOCKER_IMAGE=api-test-back install


-- Tag and Push docker images to ECR Registry 
-
docker tag api-test-front <cuenta>.dkr.ecr.us-east-1.amazonaws.com/terraform-eks-demo-ecr:api-test-front
docker push <cuenta>.dkr.ecr.us-east-1.amazonaws.com/terraform-eks-demo-ecr:api-test-front


--Commands to deploy in EKS
--

-- Namespace creation
- 
 kubectl apply -f namespace.yaml

-- namespace labeling for sidecar injection
-
kubectl label namespace api-test-ns appmesh.k8s.aws/sidecarInjectorWebhook=enabled


-- Backend EKS deployment (inside code2statebkend)
-
kubectl apply -f api-test-back.yaml
 
-- Backend EKS deployment (inside codestate)
-
kubectl apply -f api-test-front.yaml 
 
-- EKS Services (inside codestate)
-
kubectl apply -f services.yaml


 -- EKS Ingress for frontend (inside codestate)
 -
 kubectl apply -f ingress.yaml 


-- EKS Virtual Services for sidecar interception and redirection  (inside codestate)
-
kubectl apply -f virtualservices.yaml

-- EKS Virtual Services for sidecar destination 
-
kubectl apply -f virtualnodes.yaml 
 

-- Install prometheus and graphana
-
helm repo add stable https://kubernetes-charts.storage.googleapis.com

kubectl create ns prometheus

helm install prometheus  stable/prometheus -f prometheus-values.yaml --namespace prometheus

helm install grafana  stable/grafana -f grafana-values.yaml --namespace prometheus

Need to use ModHeader to override Host Header and add host: chart-example.com

--

You may test the exercise having a look on your load balancers (there should be two after all steps) and execute following commands:

Spring Boot Test
http://<alb-url>.elb.amazonaws.com/stateToCode?state=Florida

Grafana
http://<alb-url>.elb.amazonaws.com/ - user: admin pass:strongPassword*



--OTHERS
-



-- delete prometheus if desired
-
helm delete prometheus --namespace prometheus
helm delete grafana --namespace prometheus
kubectl delete namespace prometheus
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com


sh delete_others_prometheus.sh // change after "grep" the name of the chart installed to be deleted (actually in example sh my-release)

-- Do
 
 
 
-- Inside envoy to see statistics

kubectl exec -it <pod name> -n<namespace> -c envoy bash
 
curl http://localhost:9901/stats


-- delete psp if locked in grafana or prometheus

