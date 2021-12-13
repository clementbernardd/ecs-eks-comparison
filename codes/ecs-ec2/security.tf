# Security group configuration


resource "aws_security_group" "ecs-tp3-terraform-sg" {
  vpc_id = aws_vpc.ecs-tp3-vpc-terraform.id

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self = true
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}








