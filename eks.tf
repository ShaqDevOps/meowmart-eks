module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.29"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.private_1.id]

  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      instance_types = [var.instance_type]


      tags = {
        Environment = "dev"
        Terraform   = "true"
        Name        = "meowmart-node"
        auto-delete = "no"

      }

    }
  }
  node_security_group_additional_rules = {
    allow_nlb_to_pods_9000 = {
      description = "Allow NLB in public subnet to reach pods on 9000"
      protocol    = "tcp"
      from_port   = 9000
      to_port     = 9000
      type        = "ingress"
      cidr_blocks = [aws_subnet.public_1.cidr_block]
    }
  }


  tags = {
    Environment = "dev"
    Terraform   = "true"
    Name        = "meowmart-node"

  }

  enable_cluster_creator_admin_permissions = true
}
