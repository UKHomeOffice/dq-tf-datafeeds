# pylint: disable=missing-docstring, line-too-long, protected-access
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

              appsvpc_id                  = "1234"
              opssubnet_cidr_block        = "1.2.3.0/24"
              data_feeds_cidr_block       = "10.1.4.0/24"
              data_pipe_apps_cidr_block   = "1.2.3.0/24"
              az                          = "eu-west-2a"
              name_prefix                 = "dq-"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_feeds(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds"]["cidr_block"], "10.1.4.0/24")

    def test_name_prefix_data_feeds_subnet(self):
        self.assertEqual(self.result['data_feeds']["aws_subnet.data_feeds"]["tags.Name"], "dq-apps-data-feeds-subnet")

    def test_name_prefix_df_postgres(self):
        self.assertEqual(self.result['data_feeds']["aws_instance.df_postgres"]["tags.Name"], "dq-apps-data-feeds-postgres")

    def test_name_prefix_df_web(self):
        self.assertEqual(self.result['data_feeds']["aws_instance.df_web"]["tags.Name"], "dq-apps-data-feeds-web")

    def test_name_prefix_df_db(self):
        self.assertEqual(self.result['data_feeds']["aws_security_group.df_db"]["tags.Name"], "dq-apps-data-feeds-db-sg")

    def test_name_prefix_df_web(self):
        self.assertEqual(self.result['data_feeds']["aws_security_group.df_web"]["tags.Name"], "dq-apps-data-feeds-web-sg")



if __name__ == '__main__':
    unittest.main()
