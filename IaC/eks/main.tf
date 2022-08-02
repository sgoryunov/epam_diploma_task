#=====--versions--===========
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  required_version = ">= 0.14"
}
# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
provider "aws" {
  region = var.region
}

locals {
  prefix_name = "epam-edu"
  cluster_name = "${local.prefix_name}-eks"
  # cluster_name = "${local.prefix_name}-eks-${random_string.suffix.result}"
}
# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

#=========--Data--==================
# data "aws_vpc" "selected" {
#   id = var.vpc_id
# }

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
data "aws_security_groups" "sg-one" {
  tags = {
    "Number" = "one"
  }
}
data "aws_security_groups" "sg-two" {
  tags = {
    "Number" = "two"
  }
}
# data "aws_security_groups" "sg-three" {
#   tags = {
#     "Number" = "three"
#   }
# }
data "aws_security_groups" "sg-efs" {
  tags = {
    "Name" = "epam-edu"
  }
}
data "aws_route53_zone" "selected" {
  name         = "itunes-gr.ru."
  private_zone = false
}


#==========--eks--==============
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = data.aws_subnet_ids.private.ids

  vpc_id = var.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [data.aws_security_groups.sg-one.ids,data.aws_security_groups.sg-efs.ids]
      asg_desired_capacity          = 2
      key_name                      = "service"
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [data.aws_security_groups.sg-two.ids,data.aws_security_groups.sg-efs.ids]
      asg_desired_capacity          = 1
      key_name                      = "service"
    },
  ]
}

# resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
#   url = module.eks.cluster_oidc_issuer_url

#   client_id_list = [
#     "sts.amazonaws.com",
#   ]

#   thumbprint_list = ["9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"]
# }
# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }


#===========rds=================
resource "aws_security_group" "rds_security_group" {
  name_prefix = "rds_security_group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
resource "aws_db_subnet_group" "education-vpc" {
  name       = "education-vpc"
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    Name = "education-vpc"
  }
}
resource "aws_db_instance" "itunes-gr_db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_user_pass
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  identifier = "sgoryunov-db"
  db_subnet_group_name = resource.aws_db_subnet_group.education-vpc.name
  vpc_security_group_ids = [resource.aws_security_group.rds_security_group.id]
}

#==========--ecr--======================

resource "aws_ecr_repository" "itunes-gr-repo" {
  name                 = "itunes-gr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}