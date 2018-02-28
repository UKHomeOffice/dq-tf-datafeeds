data "aws_region" "current" {
  current = true
}

data "aws_ami" "df_web" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ext-feeds-linux-server*",
    ]
  }

  owners = [
    "self",
  ]
}
