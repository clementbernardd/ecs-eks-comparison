locals {
  # bootstrap script of an ec2 to join the eks cluster
  eks-nodes-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-tp3-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-tp3-cluster.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA
}


resource "aws_instance" "ec2-instance-tp3" {
  ami                         = "ami-019904275ee6b71a3"
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.public_subnet.0.id
  associate_public_ip_address = true
  key_name                    = "Ecs-tp3"
  iam_instance_profile        = "${aws_iam_instance_profile.eks-nodes-instance-profile.name}"
  vpc_security_group_ids      = [aws_security_group.eks-nodes-sg.id, aws_security_group.eks-cluster-sg.id, aws_security_group.eks-nodes-from-master.id]
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