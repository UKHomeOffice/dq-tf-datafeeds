resource "aws_db_subnet_group" "rds" {
  name = "ext_feed_rds_group"

  subnet_ids = [
    "${aws_subnet.data_feeds.id}",
    "${aws_subnet.data_feeds_az2.id}",
  ]

  tags {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_security_group" "df_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_feeds_cidr_block}",
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

resource "random_string" "datafeed_password" {
  length  = 16
  special = false
}

resource "random_string" "datafeed_username" {
  length  = 8
  special = false
  number  = false
}

resource "aws_ssm_parameter" "rds_datafeed_username" {
  name        = "rds_datafeed_username"
  type        = "SecureString"
  description = "Data feeds RDS admin username"
  value       = "${random_string.datafeed_username.result}"
}

resource "aws_ssm_parameter" "rds_datafeed_password" {
  name        = "rds_datafeed_password"
  type        = "SecureString"
  description = "Data feeds RDS admin password"
  value       = "${random_string.datafeed_password.result}"
}

resource "aws_db_instance" "datafeed_rds" {
  identifier                      = "postgres-${local.naming_suffix}"
  allocated_storage               = 100
  storage_type                    = "gp2"
  engine                          = "postgres"
  engine_version                  = "10.6"
  instance_class                  = "db.m4.large"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  username                        = "${random_string.datafeed_username.result}"
  password                        = "${random_string.datafeed_password.result}"
  name                            = "${var.datafeed_rds_db_name}"
  backup_window                   = "00:00-01:00"
  maintenance_window              = "mon:01:30-mon:02:30"
  backup_retention_period         = 14
  deletion_protection             = true
  storage_encrypted               = true
  multi_az                        = true
  skip_final_snapshot             = true

  db_subnet_group_name   = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids = ["${aws_security_group.df_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "postgres-${local.naming_suffix}"
  }
}
