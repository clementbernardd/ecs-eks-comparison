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
