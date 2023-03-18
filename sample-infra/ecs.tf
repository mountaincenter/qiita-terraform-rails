# ==============
# ECS Cluster
# ==============
resource "aws_ecs_cluster" "sample_cluster" {
  name = "${var.r_prefix}-cluster"
}

# ===================
# Task Definitions
# ===================
resource "aws_ecs_task_definition" "sample_app_nginx" {
  family                   = "sample-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # Fargateを使う場合は「awsvpc」で固定
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/ecs-task-role"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/ecs-task-role"
  cpu                      = 512
  memory                   = 1024
  container_definitions = templatefile("./task-definitions/app-nginx.json", {
    db_host          = aws_db_instance.sample_db.address
    db_name          = var.database_name
    db_password      = aws_ssm_parameter.database_password.value
    db_username      = var.database_username
    rails_master_key = aws_ssm_parameter.rails_master_key.value
  })
}

resource "aws_ecs_service" "sample_service" {
  cluster                            = aws_ecs_cluster.sample_cluster.id
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  name                               = "sample-service"
  task_definition                    = aws_ecs_task_definition.sample_app_nginx.arn
  desired_count                      = 1 # 常に1つのタスクが稼働する状態にする

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.sample_alb_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    # subnets = [
    #   for value in aws_subnet.sample_public_subnet : value.id
    # ]
    subnets = values(aws_subnet.sample_public_subnet)[*].id
    security_groups = [
      aws_security_group.sample_sg_app.id,
      aws_security_group.sample_sg_db.id
    ]
    assign_public_ip = "true"
  }
}