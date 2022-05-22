#! /bin/bash
# configure kubctl
aws eks --region $(terraform -chdir=IaC/ output -raw region) update-kubeconfig --name $(terraform -chdir=IaC/ output -raw cluster_name)
# save infrastructure data
terraform -chdir=IaC/ output -raw db_endpoint
echo 'Saving infrastructure data --> Ok'
# set database endpoint

kubectl apply -f backend/secret.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/hpa.yaml
kubectl apply -f backend/service.yaml
echo 'Start backend --> Ok'
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/hpa.yaml
kubectl apply -f frontend/service.yaml
echo 'Start frontend --> Ok'
