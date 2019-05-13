locals {
  naming_suffix = "datafeeds-${var.naming_suffix}"
}

resource "aws_subnet" "data_feeds" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_feeds_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_feeds_rt_association" {
  subnet_id      = "${aws_subnet.data_feeds.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_subnet" "data_feeds_az2" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_feeds_cidr_block_az2}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az2}"

  tags {
    Name = "az2-subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_feeds_rt_rds" {
  subnet_id      = "${aws_subnet.data_feeds_az2.id}"
  route_table_id = "${var.route_table_id}"
}
