# Security group configuration
resource "aws_security_group" "ecs-tp3-terraform-ec2-sg" {
  vpc_id = aws_vpc.ecs-tp3-vpc-terraform.id

  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
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

resource "aws_security_group" "ecs-tp3-terraform-alb-sg" {
  vpc_id = aws_vpc.ecs-tp3-vpc-terraform.id

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
#    security_groups = [aws_security_group.ecs-tp3-terraform-ec2-sg.id]
  }



}






