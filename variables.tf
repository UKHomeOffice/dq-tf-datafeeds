variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
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

variable "df_web_ip" {
  default = "10.1.4.21"
}

variable "key_name" {
  default = "test_instance"
}
