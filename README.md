# dq-tf-datafeeds

This Terraform module has one private subnet and deploys an EC2 instance representing a web server and an SQL database instance. Allowing inbound TCP traffic on port 135, inbound RDP TCP traffic on port 3389 and SQL TCP traffic on 5432.


## Connectivity

| In/Out        | Type           | Protocol | FromPort| To Port | Description |
| ------------- |:-------------:| -----:| -----:|-----:| -----:|
|INBOUND | RDP | TCP |3389 | 3389| Datafeeds Web |
|INBOUND | Custom TCP | TCP | 135 | 135 | Datafeeds Web |
|INBOUND | Custom TCP | TCP | 5432 | 5432 | Datafeeds Postgres ELB |

## Content overview

This repo controls the deployment of an application module.

It consists of the following core elements:

### main.tf

This file has most of the App modules along with basic VPC components:
- Private subnet and route table association
- Two EC2 instances using the connectivity tester module
- Security group for the SQL and Web server

### outputs.tf

Various data outputs for other modules/consumers.

### variables.tf

Input data for resources within this repo.

### tests/df_test.py

Code and resource tester with mock data. It can be expanded by adding further definitions to the unit.


## User guide

### Prepare your local environment

This project currently depends on:

* drone v0.5+dev
* terraform v0.11.1+
* terragrunt v0.13.21+
* python v3.6.3+

Please ensure that you have the correct versions installed (it is not currently tested against the latest version of Drone)

### How to run/deploy

To run tests using the [tf testsuite](https://github.com/UKHomeOffice/dq-tf-testsuite):
```shell
drone exec --repo.trusted
```
To launch:
```shell
terragrunt plan
terragrunt apply
```
