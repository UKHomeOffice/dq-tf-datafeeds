locals {
  name_prefix = "${var.name_prefix}apps-data-feeds-"
}

resource "aws_subnet" "data_feeds" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_feeds_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "${local.name_prefix}subnet"
  }
}

resource "aws_route_table_association" "data_feeds_rt_association" {
  subnet_id      = "${aws_subnet.data_feeds.id}"
  route_table_id = "${var.route_table_id}"
}

module "df_postgres" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_feeds.id}"
  user_data       = "LISTEN_tcp=0.0.0.0:5432"
  security_groups = ["${aws_security_group.df_db.id}"]
  private_ip      = "${var.df_postgres_ip}"

  tags = {
    Name             = "ec2-${var.service}-postgresql-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

module "df_web" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_feeds.id}"
  user_data       = "LISTEN_rpc=0.0.0.0:135 LISTEN_rdp=0.0.0.0:3389 CHECK_db=${var.df_postgres_ip}:5432"
  security_groups = ["${aws_security_group.df_web.id}"]
  private_ip      = "${var.df_web_ip}"

  tags = {
    Name             = "ec2-${var.service}-python-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_security_group" "df_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}db-sg"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.opssubnet_cidr_block}",
      "${var.data_feeds_cidr_block}",
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

resource "aws_security_group" "df_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}web-sg"
  }

  ingress {
    from_port = 135
    to_port   = 135
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
    ]
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
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
