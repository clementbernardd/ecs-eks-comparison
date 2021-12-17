# Cluster EKS
resource "aws_eks_cluster" "eks-tp3-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-sts.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster-sg.id]
    subnet_ids         = aws_subnet.public_subnet.*.id

    endpoint_private_access = true
    endpoint_public_access  = true

  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-cluster-policy,
    aws_iam_role_policy_attachment.eks-cluster-service-policy,
  ]
}

# Kubernetes configuration
locals {
  # kubernetes configuration
  kubernetes_config = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks-tp3-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks-tp3-cluster.certificate_authority[0].data}
  name: ${aws_eks_cluster.eks-tp3-cluster.id}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks-tp3-cluster.id}
    user: ${aws_eks_cluster.eks-tp3-cluster.id}
  name: ${aws_eks_cluster.eks-tp3-cluster.id}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.eks-tp3-cluster.id}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.eks-tp3-cluster.id}"
KUBECONFIG
}

locals {
  # default rolearn for our kubernetes cluster, to allow nodes join the cluster
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
  depends_on = [aws_eks_cluster.eks-tp3-cluster]
}

resource "local_file" "kub_config" {
    content     = local.kubernetes_config
    filename = "./kub_config.conf"
}
