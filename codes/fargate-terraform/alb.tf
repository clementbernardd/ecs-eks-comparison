resource "aws_lb" "load-balancer" {
  name = "alb"
  subnets            = data.aws_subnet_ids.default.ids
  load_balancer_type = "application"
  internal           = false
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn =aws_alb_target_group.target-group.arn
  }
}

resource "aws_alb_target_group" "target-group" {
  name = "target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  target_type = "ip"

}