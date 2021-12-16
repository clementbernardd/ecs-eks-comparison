locals {
  # bootstrap script of an ec2 to join the eks cluster
  eks-nodes-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this.endpoint}' --b64-cluster-ca '${aws_eks_cluster.this.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA
}

resource "aws_security_group" "self" {
  name        = "eks-nodes-ec2"
  vpc_id      = "${aws_vpc.eks-tp3-vpc-terraform.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "ec2-instance-tp3" {
  ami                         = "ami-019904275ee6b71a3"
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.public_subnet.0.id
  associate_public_ip_address = true
  key_name                    = "Ecs-tp3"
  iam_instance_profile        = "${aws_iam_instance_profile.eks-nodes-instance-profile.name}"
  vpc_security_group_ids      = [aws_security_group.self.id, aws_security_group.eks-nodes-self.id, aws_security_group.eks-nodes-from-master.id]
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("../../credentials/Ecs-tp3.cer")
    timeout     = "4m"
  }
  user_data = base64encode(local.eks-nodes-userdata)
  tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
}