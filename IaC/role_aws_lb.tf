# for AWS load balancer conroller
locals {
  some_id = split("/",module.eks.cluster_oidc_issuer_url)[4]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "lb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "Policy fo load balancer"

  policy = "${file("iam_policy.json")}"
}

resource "aws_iam_policy" "lb_policy_additional" {
  name        = "AWSLoadBalancerControllerAdditionalIAMPolicy"
  path        = "/"
  description = "Policy fo load balancer"

  policy = "${file("iam_policy_v1_to_v2_additional.json")}"
}

resource "aws_iam_role_policy_attachment" "lb_additional_pol_att" {
  role = resource.aws_iam_role.aws_lb_role.name
  policy_arn = resource.aws_iam_policy.lb_policy_additional.arn
}

resource "aws_iam_role" "aws_lb_role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy =jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${local.some_id}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.${var.region}.amazonaws.com/id/${local.some_id}:aud": "sts.amazonaws.com",
                    "oidc.eks.${var.region}.amazonaws.com/id/${local.some_id}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }

    ]
  })
  
}