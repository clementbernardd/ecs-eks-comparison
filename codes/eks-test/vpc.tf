locals {
  cluster_name = "EKS-cluster"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"
  name = "Demo-EKS"
  cidr  = var.vpcidr
  azs = data.aws_availability_zones.available.names
  public_subnets = var.subnetid
  enable_dns_hostnames = true
  tags = {
    "Name" = "Demo-VPC"
}
}

