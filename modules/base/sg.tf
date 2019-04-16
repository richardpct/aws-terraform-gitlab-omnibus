// Rules for Bastion
resource "aws_security_group" "bastion" {
  name   = "sg_bastion-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "bastion_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "bastion_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_allowed_ssh}"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

// Rules for DataBase
resource "aws_security_group" "database" {
  name   = "sg_database-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "database_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "database_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_inbound_webserver" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.webserver.id}"
  security_group_id        = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.database.id}"
}

resource "aws_security_group_rule" "database_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.database.id}"
}

// Rules for alb web
resource "aws_security_group" "alb_web" {
  name   = "sg_alb_web-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "alb_web_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "alb_web_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_allowed_ssh}"]
  security_group_id = "${aws_security_group.alb_web.id}"
}

resource "aws_security_group_rule" "alb_web_outbound_http" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.webserver.id}"
  security_group_id        = "${aws_security_group.alb_web.id}"
}

// Rules for alb web internal
resource "aws_security_group" "alb_web_internal" {
  name   = "sg_alb_web_internal-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "alb_web_internal_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "alb_web_internal_inbound_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.runner.id}"
  security_group_id        = "${aws_security_group.alb_web_internal.id}"
}

resource "aws_security_group_rule" "alb_web_internal_outbound_http" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.webserver.id}"
  security_group_id        = "${aws_security_group.alb_web_internal.id}"
}

// Rules for WebServer
resource "aws_security_group" "webserver" {
  name   = "sg_webserver-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "webserver_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "webserver_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_inbound_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_web.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_inbound_http_internal" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_web_internal.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "webserver_outbound_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.database.id}"
  security_group_id        = "${aws_security_group.webserver.id}"
}

// Rules for Runner
resource "aws_security_group" "runner" {
  name   = "sg_runner-${var.env}"
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "runner_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "runner_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.runner.id}"
}

resource "aws_security_group_rule" "runner_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.runner.id}"
}

resource "aws_security_group_rule" "runner_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.runner.id}"
}
