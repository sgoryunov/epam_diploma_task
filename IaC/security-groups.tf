
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
#   ingress {
#     from_port = 80
#     to_port   = 80
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
#   ingress {
#     from_port = 5000
#     to_port   = 5000
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
# }

# resource "aws_security_group" "worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }
#   ingress {
#     from_port = 80
#     to_port   = 80
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
#   ingress {
#     from_port = 5000
#     to_port   = 5000
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
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
  # ingress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"

  #   cidr_blocks = [
  #     "10.0.0.0/8",
  #   ]
  # }
  # ingress {
  #   from_port = 5000
  #   to_port   = 5000
  #   protocol  = "tcp"

  #   cidr_blocks = [
  #     "10.0.0.0/8",
  #   ]
  # }
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
  # ingress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"

  #   cidr_blocks = [
  #     "10.0.0.0/8",
  #   ]
  # }
  # ingress {
  #   from_port = 5000
  #   to_port   = 5000
  #   protocol  = "tcp"

  #   cidr_blocks = [
  #     "10.0.0.0/8",
  #   ]
  # }
}