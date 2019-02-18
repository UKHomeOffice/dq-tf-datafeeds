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
              data_pipe_apps_cidr_block        = "1.2.3.0/24"
              peering_cidr_block               = "1.1.1.0/24"
              dq_database_cidr_block_secondary = ["10.1.1.0/24"]
              az                               = "eu-west-2a"
              az2                              = "eu-west-2b"
              naming_suffix                    = "apps-preprod-dq"
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

    def test_name_suffix_df_web(self):
        self.assertEqual(self.result['data_feeds']["aws_security_group.df_web"]["tags.Name"], "sg-web-datafeeds-apps-preprod-dq")

    def test_subnet_group(self):
        self.assertEqual(self.result['data_feeds']["aws_db_subnet_group.rds"]["tags.Name"], "rds-subnet-group-datafeeds-apps-preprod-dq")

    def test_az2_subnet(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds_az2"]["tags.Name"], "az2-subnet-datafeeds-apps-preprod-dq")

    def test_rds_name(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.postgres"]["tags.Name"], "ext-postgres-datafeeds-apps-preprod-dq")

    def test_rds_id(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.postgres"]["identifier"], "ext-postgres-datafeeds-apps-preprod-dq")

    def test_datafeed_rds_name(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["tags.Name"], "postgres-datafeeds-apps-preprod-dq")

    def test_datafeed_rds_id(self):
        self.assertEqual(self.result['data_feeds']["aws_db_instance.datafeed_rds"]["identifier"], "postgres-datafeeds-apps-preprod-dq")

if __name__ == '__main__':
    unittest.main()
