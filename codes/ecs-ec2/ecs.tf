resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-tp3-cluster"
}

resource "aws_ecr_repository" "worker" {
    name  = "worker"
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "ecs-tp3-task"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  task_role_arn = aws_iam_role.ecsTaskExecution_role.arn
  execution_role_arn = aws_iam_role.ecsTaskExecution_role.arn
  container_definitions = jsonencode([
    {
      name      = "app2"
      image     = "803716525692.dkr.ecr.us-east-1.amazonaws.com/application2:latest"
      cpu       = 2
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "worker" {
  name = "Ecs-tp3-service"
  launch_type = "EC2"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.ec2_tg.arn
    container_name = "app2"
    container_port = 80
  }
}