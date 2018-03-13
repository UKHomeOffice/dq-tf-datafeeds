resource "aws_iam_role" "data_feeds_linux_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "data_feeds_linux_iam" {
  role = "${aws_iam_role.data_feeds_linux_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:PutParameter",
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:*:parameter/ef_ssh_logon",
        "arn:aws:ssm:eu-west-2:*:parameter/DRT_BUCKET_NAME",
        "arn:aws:ssm:eu-west-2:*:parameter/DRT_AWS_ACCESS_KEY_ID",
        "arn:aws:ssm:eu-west-2:*:parameter/DRT_AWS_SECRET_ACCESS_KEY",
        "arn:aws:ssm:eu-west-2:*:parameter/ef_rds_dns_name",
        "arn:aws:ssm:eu-west-2:*:parameter/EF_DB_USER",
        "arn:aws:ssm:eu-west-2:*:parameter/EF_DB",
        "arn:aws:ssm:eu-west-2:*:parameter/ef_dbuser_password",
        "arn:aws:ssm:eu-west-2:*:parameter/gpadmin_public_key",
        "arn:aws:ssm:eu-west-2:*:parameter/addomainjoin"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "data_feeds_linux" {
  role = "${aws_iam_role.data_feeds_linux_iam_role.name}"
}
