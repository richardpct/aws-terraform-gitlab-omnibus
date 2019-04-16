resource "aws_lb" "web" {
  name               = "alb-web-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_web.id}"]
  subnets            = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
}

resource "aws_lb_target_group" "web" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.my_vpc.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 3
    interval            = 60
    path                = "/"
    matcher             = 302
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_lb" "web_internal" {
  name               = "alb-web-internal-${var.env}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_web_internal.id}"]
  subnets            = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
}

resource "aws_lb_target_group" "web_internal" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.my_vpc.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 3
    interval            = 60
    path                = "/"
    matcher             = 302
  }
}

resource "aws_lb_listener" "web_internal" {
  load_balancer_arn = "${aws_lb.web_internal.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web_internal.arn}"
    type             = "forward"
  }
}
