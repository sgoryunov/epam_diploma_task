#! /bin/bash
set -e
# create vpc 
# terraform -chdir=IaC init
# terraform -chdir=IaC/vpc apply

# init terraform by secrets
ansible-playbook --vault-password-file secret.txt terraform_init.yml 
echo 'Terraform files init --> Ok'

# start terraform 
# terraform -chdir=IaC init
terraform -chdir=IaC/eks apply -var="vpc_id=$(terraform -chdir=IaC/vpc output -raw vpc_id)"
# terraform -chdir=IaC/eks apply 
echo 'Create infrastructure --> Ok'

# configure kubctl
aws eks --region $(terraform -chdir=IaC/eks/ output -raw region) update-kubeconfig --name $(terraform -chdir=IaC/eks/ output -raw cluster_name)
echo 'Configure kubectl --> Ok'

# init secrets, Jenkins, Prometheus, Sonarqube.
str=$(terraform -chdir=IaC/eks output -raw db_endpoint)
ansible-playbook --vault-password-file secret.txt -e db_ep=${str%:*} \
                 -e efs_id=$(terraform -chdir=IaC/vpc output -raw efs_id) manifest_init.yml
kubectl apply -f backend/rds_controller.yaml
kubectl apply -f backend/secret.yaml
echo 'Configure k8s resources --> Ok'


# create aws load balancer controller 
# install certifitate manager
# kubectl apply \
#     --validate=false \
#     -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
# kubectl apply -f frontend/aws-load-balancer-controller-service-account.yaml
# helm repo add eks https://aws.github.io/eks-charts
# helm repo update
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
#   -n kube-system \
#   --set clusterName=$(terraform -chdir=IaC/ output -raw cluster_name) \
#   --set serviceAccount.create=false \
#   --set serviceAccount.name=aws-load-balancer-controller 
# echo 'Create ALB controller --> Ok'

# create nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/aws/deploy.yaml
# create cert manager
kubectl create namespace cert-manager
# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
helm repo add jetstack https://charts.jetstack.io && helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.1.0 \
  --set installCRDs=true


# start app
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/hpa.yaml
kubectl apply -f backend/service.yaml
echo 'Start backend --> Ok'
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/hpa.yaml  
kubectl apply -f frontend/service.yaml
sleep 30s
kubectl apply -f frontend/ingress_nlb.yaml
echo 'Start frontend --> Ok'

#===-jenkins deploy-======
# deploy EFS storage driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
#Setup a namespace
kubectl create ns jenkins
kubectl get storageclass
# create volume
kubectl apply -f ./k8s/jenkins/aws/jenkins.pv.yaml 
kubectl get pv
# create volume claim
kubectl apply -n jenkins -f ./k8s/jenkins/aws/jenkins.pvc.yaml
kubectl -n jenkins get pvc
### Deploy Jenkins
# rbac
kubectl apply -n jenkins -f ./k8s/jenkins/aws/jenkins.rbac.yaml 
kubectl apply -n jenkins -f ./k8s/jenkins/aws/jenkins.deployment.yaml
kubectl -n jenkins get pods
### Expose a service for agents
kubectl apply -n jenkins -f ./k8s/jenkins/aws/jenkins.service.yaml 