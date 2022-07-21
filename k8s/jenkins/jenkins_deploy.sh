#! /bin/bash

set -e 
#===-in_k8s-========
# kubectl create namespace jenkins
# helm repo add jenkinsci https://charts.jenkins.io && helm repo update
# kubectl apply -f jenkins-volume.yaml
# kubectl apply -f jenkins-sa.yaml
# helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins

#===-in_eks-===
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