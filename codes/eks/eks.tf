module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.1.0"
  cluster_name = local.cluster_name
  cluster_version = "1.20"
  subnets = module.vpc.public_subnets
  tags = {
    Name = "Demo-EKS-cluster"
  }
  vpc_id = module.vpc.vpc_id
  workers_group_defaults = {
        root_volume_type = "gp2"
    }
  worker_groups = [
    {
      name = "Worker-Group-1"
      instance_type = "t2.micro"
      additional_security_group_ids = [aws_security_group.worker_group.id]
    },
    {
      name = "Worker-Group-2"
      instance_type = "t2.micro"
      additional_security_group_ids = [aws_security_group.worker_group_two.id]
    }

  ]

}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
