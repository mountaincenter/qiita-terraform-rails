resource "aws_alb" "sample_alb" {
  name            = "${var.r_prefix}-alb"
  security_groups = [aws_security_group.sample_sg_alb.id]

  subnets = [
    for value in aws_subnet.sample_public_subnet : value.id
  ]

  internal                   = false
  enable_deletion_protection = false

  access_logs {
    bucket = aws_s3_bucket.sample_alb_logs.bucket
  }
}

resource "aws_alb_target_group" "sample_alb_tg" {
  name                 = "${var.r_prefix}-alb-tg"
  port                 = 80
  depends_on           = [aws_alb.sample_alb]
  target_type          = "ip"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.sample_vpc.id
  deregistration_delay = 15

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "sample_alb_listener" {
  port     = "80"
  protocol = "HTTP"

  load_balancer_arn = aws_alb.sample_alb.arn

  # default_action {
  #   target_group_arn = aws_alb_target_group.sample_alb_tg.arn
  #   type             = "forward"
  # }
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_alb_listener_rule" "sample_alb_listener_rule" {
#   depends_on   = [aws_alb_target_group.sample_alb_tg]
#   listener_arn = aws_alb_listener.sample_alb_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.sample_alb_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/"]
#     }
#   }
# }

resource "aws_alb_listener" "sample_alb_listener_https" {
  load_balancer_arn = aws_alb.sample_alb.arn
  certificate_arn   = aws_acm_certificate.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sample_alb_tg.id
  }
  depends_on = [
    aws_acm_certificate_validation.main
  ]
}
