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
# ansible-playbook --vault-password-file secret.txt -e db_ep=$(terraform -chdir=IaC/ output -raw db_endpoint) manifest_init.yml
kubectl apply -f backend/rds_controller.yaml
kubectl apply -f backend/secret.yaml
echo 'Configure k8s resources --> Ok'

# start app
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/hpa.yaml
kubectl apply -f backend/service.yaml
echo 'Start backend --> Ok'
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/hpa.yaml
kubectl apply -f frontend/service.yaml
echo 'Start frontend --> Ok'
