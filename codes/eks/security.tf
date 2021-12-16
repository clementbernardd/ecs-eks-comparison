
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow traffic"
  vpc_id      = aws_vpc.eks-tp3-vpc-terraform.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = "eks-cluster-sg"
  description = "Allow traffic between EKS nodes and API"
  vpc_id      = aws_vpc.eks-tp3-vpc-terraform.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks-nodes-self.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EKS nodes internal communication
resource "aws_security_group" "eks-nodes-self" {
  name        = "eks-nodes-sg"
  vpc_id      = aws_vpc.eks-tp3-vpc-terraform.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true # Allow communication between nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# EKS nodes communication from master
resource "aws_security_group" "eks-nodes-from-master" {
  name        = "eks-nodes-from-master-"
  vpc_id      = aws_vpc.eks-tp3-vpc-terraform.id


  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks-nodes-self.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
