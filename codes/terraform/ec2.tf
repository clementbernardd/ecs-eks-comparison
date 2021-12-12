# Ec2 creation
resource "aws_instance" "ec2-instance-tp3" {
  ami                         = "ami-083654bd07b5da81d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.0.id
  associate_public_ip_address = true
  key_name                    = "Ecs-tp3"
  vpc_security_group_ids      = [aws_security_group.ecs-tp3-terraform-sg.id]
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/Ecs-tp3.cer")
    timeout     = "4m"
  }
}