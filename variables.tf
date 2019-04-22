variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_feeds_cidr_block" {}
variable "peering_cidr_block" {}
variable "az" {}
variable "az2" {}
variable "data_feeds_cidr_block_az2" {}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "datafeed_rds_db_name" {
  default = "ef_db"
}

variable "lambda_sgrp" {
  default = "sg-08a996ab577bdb8aa"
}

variable "dq_lambda_subnet_cidr" {
  default     = "10.1.42.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}

variable "dq_lambda_subnet_cidr_az2" {
  default     = "10.1.43.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}
