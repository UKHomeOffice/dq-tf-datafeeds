output "data_feeds_subnet_id" {
  value = "${aws_subnet.data_feeds.id}"
}

output "df_db_sg" {
  value = "${aws_security_group.df_db.id}"
}

output "rds_address" {
  value = "${aws_db_instance.datafeed_rds.address}"
}
