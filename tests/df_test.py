# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "data_feeds" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }

              appsvpc_id                       = "1234"
              opssubnet_cidr_block             = "1.2.3.0/24"
              data_feeds_cidr_block            = "10.1.4.0/24"
              data_feeds_cidr_block_az2        = "10.1.5.0/24"
              peering_cidr_block               = "1.1.1.0/24"
              az                               = "eu-west-2a"
              az2                              = "eu-west-2b"
              naming_suffix                    = "apps-preprod-dq"
              environment                      = "prod"
              rds_enhanced_monitoring_role     = "arn:aws:iam::123456789:role/rds-enhanced-monitoring-role"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_feeds(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds"]["cidr_block"], "10.1.4.0/24")

    def test_name_suffix_data_feeds(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds"]["tags.Name"], "subnet-datafeeds-apps-preprod-dq")

    def test_name_suffix_df_db(self):
        self.assertEqual(self.result['data_feeds']["aws_security_group.df_db"]["tags.Name"], "sg-db-datafeeds-apps-preprod-dq")

    def test_subnet_group(self):
        self.assertEqual(self.result['data_feeds']["aws_db_subnet_group.rds"]["tags.Name"], "rds-subnet-group-datafeeds-apps-preprod-dq")

    def test_az2_subnet(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds_az2"]["tags.Name"], "az2-subnet-datafeeds-apps-preprod-dq")

    def test_datafeed_rds_name(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["tags.Name"], "postgres-datafeeds-apps-preprod-dq")

    def test_datafeed_rds_id(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["identifier"], "postgres-datafeeds-apps-preprod-dq")

    def test_datafeed_rds_deletion_protection(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["deletion_protection"], "true")

    def test_datafeed_rds_ca_cert_identifier(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["ca_cert_identifier"], "rds-ca-2019")

    def test_datafeed_rds_backup_window(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["backup_window"], "00:00-01:00")

    def test_datafeed_rds_maintenance_window(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["maintenance_window"], "mon:01:00-mon:02:00")

    def test_datafeed_rds_engine_version(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["engine_version"], "10.10")

    def test_datafeed_rds_apply_immediately(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["apply_immediately"], "false")

if __name__ == '__main__':
    unittest.main()
