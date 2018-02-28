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

resource "aws_instance" "df_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.df_web.id}"
  instance_type               = "t2.xlarge"
  vpc_security_group_ids      = ["${aws_security_group.df_web.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_feeds.id}"
  private_ip                  = "${var.df_web_ip}"

  tags = {
    Name = "python-${local.naming_suffix}"
  }
}

resource "aws_security_group" "df_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
