variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "data_feeds_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "df_postgres_ip" {
  description = "Mock IP address of database EC2 instance"
  default     = "10.1.4.11"
}

variable "df_web_ip" {
  description = "Mock IP address of web EC2 instance"
  default     = "10.1.4.21"
}

variable "service" {
  default     = "dq-external-feed"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment" {
  default     = "preprod"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment_group" {
  default     = "dq-apps"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}
