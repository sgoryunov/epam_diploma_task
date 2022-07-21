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

    # null = {
    #   source  = "hashicorp/null"
    #   version = "3.1.0"
    # }

    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">= 2.0.1"
    # }
  }

  required_version = ">= 0.14"
}

#==========--vpc--========================

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  prefix_name = "epam-edu"
  cluster_name = "${local.prefix_name}-eks"
  # cluster_name = "${local.prefix_name}-eks-${random_string.suffix.result}"

}

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${local.prefix_name}-vpc"

  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

#==========--security groups--==================

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  tags = {
    "Number" = "one"
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
      "10.0.0.0/16"
    ]
  }
  tags = {
    "Number" = "two"
  }
}

resource "aws_security_group" "worker_group_mgmt_three" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
  tags = {
    "Number" = "three"
  }
}
#=========--efs--==================
module "efs" {
  source                 = "AustinCloudGuru/efs/aws"
  # You should pin the module to a specific version
  version              = "1.0.9"
  vpc_id                 = module.vpc.vpc_id
  name                   = "${local.prefix_name}-efs"
  subnet_ids             = module.vpc.private_subnets
  security_group_ingress = {
                             default = {
                               description = "NFS Inbound"
                               from_port   = 2049
                               protocol    = "tcp"
                               to_port     = 2049
                               self        = true
                              #  cidr_blocks = [
                                #   "10.0.0.0/8",
                                #   "172.16.0.0/12",
                                #   "192.168.0.0/16",
                                # ]
                               cidr_blocks = null
                             },
                             ssh = {
                               description = "ssh"
                               from_port   = 22
                               protocol    = "tcp"
                               to_port     = 22
                               self        = false
                               cidr_blocks = ["10.0.0.0/16"]
                             }
                           }
  lifecycle_policy = [{
                        "transition_to_ia" = "AFTER_30_DAYS"
                     }]
  tags          = {
                    Name = local.prefix_name
                  } 
}


#========--route53--===============
# resource "aws_route53_zone" "example" {
#   name = "example.com"

#   # NOTE: The aws_route53_zone vpc argument accepts multiple configuration
#   #       blocks. The below usage of the single vpc configuration, the
#   #       lifecycle configuration, and the aws_route53_zone_association
#   #       resource is for illustrative purposes (e.g., for a separate
#   #       cross-account authorization process, which is not shown here).
#   vpc {
#     vpc_id = aws_vpc.primary.id
#   }

#   lifecycle {
#     ignore_changes = [vpc]
#   }
# }
# data "aws_route53_zone" "selected" {
#   name         = "itunes-gr.ru."
#   private_zone = false
# }

# resource "aws_route53_record" "acm_verification" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
#   name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
#   ttl     = "300"
#   records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
# }

# // This resource doesn't create anything
# // it just waits for the certificate to be created, and validation to succeed, before being created
# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.acm_verification.fqdn]
# }
