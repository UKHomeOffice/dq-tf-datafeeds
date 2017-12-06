output "data_feeds_subnet_id" {
  value = "${aws_subnet.data_feeds.id}"
}

output "df_db_sg" {
  value = "${aws_security_group.df_db.id}"
}

output "df_web_sg" {
  value = "${aws_security_group.df_web.id}"
}

output "data_feeds_cidr_block" {
  value = "${var.data_feeds_cidr_block}"
}

output "df_postgres_ip" {
  value = "${var.df_postgres_ip}"
}

output "df_web_ip" {
  value = "${var.df_web_ip}"
}
