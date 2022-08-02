#! /bin/bash
set -e
terraform -chdir=IaC/eks destroy -var="vpc_id=$(terraform -chdir=IaC/vpc output -raw vpc_id)"

# delete load balncer
aws elbv2 delete-load-balancer --load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[*].LoadBalancerArn" --output text)
