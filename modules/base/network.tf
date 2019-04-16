data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "my_vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "my_igw-${var.env}"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.subnet_public_a}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "subnet_public_a-${var.env}"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.subnet_public_b}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "subnet_public_b-${var.env}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "${var.subnet_private}"

  tags {
    Name = "subnet_private-${var.env}"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name = "eip_nat-${var.env}"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_a.id}"

  tags {
    Name = "nat_gw-${var.env}"
  }
}

resource "aws_default_route_table" "route" {
  default_route_table_id = "${aws_vpc.my_vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "default_route-${var.env}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_igw.id}"
  }

  tags {
    Name = "custom_route-${var.env}"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_default_route_table.route.id}"
}

resource "aws_eip" "bastion" {
  vpc = true

  tags {
    Name = "eip_bastion-${var.env}"
  }
}
