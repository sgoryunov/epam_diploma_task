#! /bin/bash
# set -e
# # init terraform by secrets
# ansible-playbook --vault-password-file secret.txt terraform_init.yml 
# echo 'Terraform files init --> Ok'

# # start terraform 
# # terraform -chdir=IaC init
# terraform -chdir=IaC apply 
# echo 'Create infrastructure --> Ok'

# # configure kubctl
# aws eks --region $(terraform -chdir=IaC/ output -raw region) update-kubeconfig --name $(terraform -chdir=IaC/ output -raw cluster_name)
# echo 'Configure kubectl --> Ok'

# # init secrets, Jenkins, Prometheus, Sonarqube.
# str=$(terraform -chdir=IaC/ output -raw db_endpoint)
# ansible-playbook --vault-password-file secret.txt -e db_ep=${str%:*} manifest_init.yml
# kubectl apply -f backend/rds_controller.yaml
# kubectl apply -f backend/secret.yaml
# echo 'Configure k8s resources --> Ok'
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
# start app
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/hpa.yaml
kubectl apply -f backend/service.yaml
echo 'Start backend --> Ok'
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/hpa.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/ingress_nlb.yaml
echo 'Start frontend --> Ok'