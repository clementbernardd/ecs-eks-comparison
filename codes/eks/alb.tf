# Target group
resource "aws_lb_target_group" "ec2_tg" {
  name = "Ec2-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.eks-tp3-vpc-terraform.id
  target_type = "instance"
  depends_on = [aws_lb.load_balancer]
}

# Application load balancer
resource "aws_lb" "load_balancer" {
  name = "eks-load-balancer"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id, aws_security_group.eks-nodes-sg.id]
  subnets = aws_subnet.public_subnet.*.id
}

# Listener
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.ec2_tg.arn
  target_id        = aws_instance.ec2-instance-tp3.id
}

output "alb_dnsname" {
  value = aws_lb.load_balancer.dns_name
}
