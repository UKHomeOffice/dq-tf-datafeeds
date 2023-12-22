resource "aws_db_subnet_group" "rds" {
  name = "ext_feed_rds_group"

  subnet_ids = [
    aws_subnet.data_feeds.id,
    aws_subnet.data_feeds_az2.id,
  ]

  tags = {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_security_group" "df_db" {
  vpc_id = var.appsvpc_id

  tags = {
    Name = "sg-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      var.opssubnet_cidr_block,
      var.data_feeds_cidr_block,
      var.peering_cidr_block,
      var.dq_lambda_subnet_cidr,
      var.dq_lambda_subnet_cidr_az2,
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
  numeric  = false
}

resource "aws_ssm_parameter" "rds_datafeed_username" {
  name        = "rds_datafeed_username"
  type        = "SecureString"
  description = "Data feeds RDS admin username"
  value       = random_string.datafeed_username.result
}

resource "aws_ssm_parameter" "rds_datafeed_password" {
  name        = "rds_datafeed_password"
  type        = "SecureString"
  description = "Data feeds RDS admin password"
  value       = random_string.datafeed_password.result
}

resource "aws_db_instance" "datafeed_rds" {
  identifier                      = "postgres-${local.naming_suffix}"
  allocated_storage               = 100
  storage_type                    = "gp2"
  engine                          = "postgres"
  engine_version                  = var.environment == "prod" ? "14.7" : "14.7"
  instance_class                  = var.environment == "prod" ? "db.m5.xlarge" : "db.m5.large"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  username                        = random_string.datafeed_username.result
  password                        = random_string.datafeed_password.result
  db_name                         = var.datafeed_rds_db_name
  backup_window                   = var.environment == "prod" ? "00:00-01:00" : "07:00-08:00"
  maintenance_window              = var.environment == "prod" ? "mon:01:00-mon:02:00" : "mon:08:00-mon:09:00"
  backup_retention_period         = 14
  deletion_protection             = true
  storage_encrypted               = true
  multi_az                        = var.environment == "prod" ? "true" : "false"
  skip_final_snapshot             = true
  ca_cert_identifier              = var.environment == "prod" ? "rds-ca-2019" : "rds-ca-2019"
  apply_immediately               = var.environment == "prod" ? "false" : "true"
  monitoring_interval             = "60"
  monitoring_role_arn             = var.rds_enhanced_monitoring_role
  db_subnet_group_name            = aws_db_subnet_group.rds.id
  vpc_security_group_ids          = [aws_security_group.df_db.id]

  performance_insights_enabled          = true
  performance_insights_retention_period = "7"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      engine_version,
    ]
  }

  tags = {
    Name = "postgres-${local.naming_suffix}"
  }
}

module "rds_alarms" {
  source = "github.com/UKHomeOffice/dq-tf-cloudwatch-rds?ref=yel-8750-migrate-tf-version"

  naming_suffix                = local.naming_suffix
  environment                  = var.naming_suffix
  pipeline_name                = "DRT-data-feed"
  db_instance_id               = aws_db_instance.datafeed_rds.id
  free_storage_space_threshold = 30000000000 # 30GB free space
  read_latency_threshold       = 0.1         # 100 milliseconds
  write_latency_threshold      = 0.35        # 350 milliseconds
}
