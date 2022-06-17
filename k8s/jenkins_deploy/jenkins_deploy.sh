#! /bin/bash

set -e 
kubectl create namespace jenkins
helm repo add jenkinsci https://charts.jenkins.io && helm repo update
kubectl apply -f jenkins-volume.yaml
kubectl apply -f jenkins-sa.yaml
helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins