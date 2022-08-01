#! /bin/bash
echo Start!
# init secrets, Jenkins, Prometheus, Sonarqube.
str=$(terraform -chdir=IaC/eks output -raw db_endpoint)
ansible-playbook --vault-password-file secret.txt -e db_ep=${str%:*} \
                 -e efs_id=$(terraform -chdir=IaC/vpc output -raw efs_id) manifest_init.yml
kubectl apply -f backend/rds_controller.yaml
kubectl apply -f backend/secret.yaml
echo 'Configure k8s resources --> Ok'
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
kubectl apply -f frontend/ingress_nlb.yaml
echo 'Start frontend --> Ok'

# jenkins deploy
