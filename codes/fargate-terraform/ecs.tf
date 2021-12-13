resource "aws_ecs_cluster" "cluster" {
  name = "ecs-fargate-terraform"
}

data "template_file" "app2" {
  template = file("./app.json.tpl")
}


resource "aws_ecs_task_definition" "task-definition" {
  family = "ecs-tp3-task-definition"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode([
  {
    name: "app2",
    image: "803716525692.dkr.ecr.us-east-1.amazonaws.com/application2:latest",
    portMappings: [
      {
        containerPort: 80,
        hostPort: 80,
        protocol: "tcp"
      }
    ],
    cpu: 1,
    memory: 1024,
  }
])
}

resource "aws_ecs_service" "ecs-service" {
  name = "ecs-tp3-service"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnet_ids.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.target-group.arn
    container_name   = aws_ecs_task_definition.task-definition.family
    container_port   = 5000
  }
  depends_on = [aws_lb_listener.http_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

}