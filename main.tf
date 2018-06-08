locals {
  naming_suffix = "datafeeds-${var.naming_suffix}"
}

resource "aws_subnet" "data_feeds" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_feeds_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_feeds_rt_association" {
  subnet_id      = "${aws_subnet.data_feeds.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_instance" "df_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.df_web.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.data_feeds_linux.id}"
  instance_type               = "t2.xlarge"
  vpc_security_group_ids      = ["${aws_security_group.df_web.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_feeds.id}"
  private_ip                  = "${var.df_web_ip}"
  monitoring                  = true

  user_data = <<EOF
#!/bin/bash

if [ ! -f /bin/aws ]; then
    curl https://bootstrap.pypa.io/get-pip.py | python
    pip install awscli
fi

aws --region eu-west-2 ssm get-parameter --name ef_ssh_logon --query 'Parameter.Value' --output text --with-decryption > /home/wherescape/.ssh/authorized_keys
aws --region eu-west-2 ssm get-parameter --name gpadmin_public_key --query 'Parameter.Value' --output text --with-decryption >> /home/wherescape/.ssh/authorized_keys

sudo touch /etc/profile.d/script_envs.sh
sudo setfacl -m u:wherescape:rwx /etc/profile.d/script_envs.sh

sudo -u wherescape echo "
export BUCKET_NAME=`aws --region eu-west-2 ssm get-parameter --name DRT_BUCKET_NAME --query 'Parameter.Value' --output text --with-decryption`
export EF_DB_HOST=`aws --region eu-west-2 ssm get-parameter --name ef_rds_dns_name --query 'Parameter.Value' --output text --with-decryption`
export EF_DB_USER=`aws --region eu-west-2 ssm get-parameter --name EF_DB_USER --query 'Parameter.Value' --output text --with-decryption`
export EF_DB=`aws --region eu-west-2 ssm get-parameter --name EF_DB --query 'Parameter.Value' --output text --with-decryption`
export PGPASSWORD=`aws --region eu-west-2 ssm get-parameter --name ef_dbuser_password --query 'Parameter.Value' --output text --with-decryption`
export DRT_AWS_ACCESS_KEY_ID=`aws --region eu-west-2 ssm get-parameter --name DRT_AWS_ACCESS_KEY_ID --query 'Parameter.Value' --output text --with-decryption`
export DRT_AWS_SECRET_ACCESS_KEY=`aws --region eu-west-2 ssm get-parameter --name DRT_AWS_SECRET_ACCESS_KEY --query 'Parameter.Value' --output text --with-decryption`
export KMS_ID=`aws --region eu-west-2 ssm get-parameter --name DRT_AWS_KMS_KEY_ID --query 'Parameter.Value' --output text --with-decryption`
export DEBUG=`aws --region eu-west-2 ssm get-parameter --name DRT_AWS_DEBUG --query 'Parameter.Value' --output text --with-decryption`
" > /etc/profile.d/script_envs.sh

su -c "/etc/profile.d/script_envs.sh" - wherescape

export DOMAIN_JOIN=`aws --region eu-west-2 ssm get-parameter --name addomainjoin --query 'Parameter.Value' --output text --with-decryption`
yum -y install sssd realmd krb5-workstation adcli samba-common-tools expect
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl reload sshd
chkconfig sssd on
systemctl start sssd.service
echo "%Domain\\ Admins@dq.homeoffice.gov.uk ALL=(ALL:ALL) ALL" >>  /etc/sudoers
expect -c "spawn realm join -U domain.join@dq.homeoffice.gov.uk DQ.HOMEOFFICE.GOV.UK; expect \"*?assword for domain.join@DQ.HOMEOFFICE.GOV.UK:*\"; send -- \"$DOMAIN_JOIN\r\" ; expect eof"
systemctl restart sssd.service
reboot

EOF

  tags = {
    Name = "python-${local.naming_suffix}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "df_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}",
      "${var.dq_database_cidr_block}",
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
