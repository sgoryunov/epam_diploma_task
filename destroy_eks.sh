#! /bin/bash

terraform -chdir=IaC/eks destroy -var="vpc_id=$(terraform -chdir=IaC/vpc output -raw vpc_id)"