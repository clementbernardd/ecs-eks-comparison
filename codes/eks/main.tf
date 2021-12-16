resource "aws_iam_role" "eks-cluster-sts" {
  name = "eks-cluster-sts"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-sts.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-sts.name
}


resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-sts.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster-sg.id]
    subnet_ids         = aws_subnet.public_subnet.*.id

    endpoint_private_access = true
    endpoint_public_access  = true

    #public_access_cidrs = [var.vpcidr]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-cluster-policy,
    aws_iam_role_policy_attachment.eks-cluster-service-policy,
  ]
}


# IAM role allowing Kubernetes actions to access other AWS services
resource "aws_iam_role" "eks-nodes-sts" {
  name = "eks-nodes-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-nodes-worker-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes-sts.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes-sts.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-ec2-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes-sts.name
}

resource "aws_iam_instance_profile" "eks-nodes-instance-profile" {
  name = "eks-nodes-tp3"
  role = aws_iam_role.eks-nodes-sts.name
}

#################################################
# Kubernetes configuration
locals {
  # kubernetes configuration
  kubernetes_config = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${aws_eks_cluster.this.certificate_authority[0].data}
  name: ${aws_eks_cluster.this.id}
contexts:
- context:
    cluster: ${aws_eks_cluster.this.id}
    user: ${aws_eks_cluster.this.id}
  name: ${aws_eks_cluster.this.id}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.this.id}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.this.id}"
KUBECONFIG
}

locals {
  # default rolearn for our kubernetes cluster, to allow our nodes join the cluster
  aws_auth_configmap_default_roles = [
    {
      rolearn : aws_iam_role.eks-nodes-sts.arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : ["system:bootstrappers", "system:nodes"]
  }]
}


resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(concat(local.aws_auth_configmap_default_roles, []))
  }
  depends_on = [aws_eks_cluster.this]
}









