data "aws_lb" "blazordev-lb-web" {
  arn = aws_lb.blazordev-lb-web.arn
}

resource "aws_lb" "blazordev-lb-web" {
  name               = "blazordev-lb-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg1.id]
  subnets            = [aws_subnet.sn1.id, aws_subnet.sn2.id]
  tags = {
    env = "dev"
  }
}

# data "aws_lb_target_group" "blazorappdev-lb-target-group" {
#   arn = aws_lb_target_group.blazorappdev-lb-target-group.arn
# }

resource "aws_lb_target_group" "blazorappdev-lb-target-group" {
  name        = "blazorappdev-lb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "blazorappdev-lb-listener" {
  load_balancer_arn = aws_lb.blazordev-lb-web.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blazorappdev-lb-target-group.arn
  }
}

# data "aws_lb_target_group" "blazorservicedev-lb-target-group" {
#   arn = aws_lb_target_group.blazorservicedev-lb-target-group.arn
# }

resource "aws_lb_target_group" "blazorservicedev-lb-target-group" {
  name        = "blazorservicedev-lb-target-group"
  port        = 81
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "blazorservicedev-lb-listener" {
  load_balancer_arn = aws_lb.blazordev-lb-web.arn
  port              = 81
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blazorservicedev-lb-target-group.arn
  }
}