# Configure the AWS Provider
provider "aws" {
  region                  = var.aws-region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
}
# We find AMI for Centos 7
  data "aws_ami" "centos" {
    most_recent = true
    owners      = ["aws-marketplace"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["CentOS Linux 7*"]
  }
}
data "aws_caller_identity" "current" {}

resource "aws_vpc" "netology-vpc" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = "netology-vpc"
  }
}

resource "aws_key_pair" "laptop" {
  key_name   = "laptop"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLw+6CgOB83CPedJBfTpkD23C+LnJBBGlJjnHZIsVk+NAYRbOaiS13+sIrJVZH1nyCthadB+JP/ESP3Zlq5UYt1shIsay9yx8BdrOI+OsZDnXAgHIJ+dq2sIBOd+N4n09ZjUh9znUuHDIZ3U3r5rMIV1qKPhnVVXGgc3fcUQiS5Zl5tpmBvSqsV8olBWZA57+T+J3h9mqxs1+dsW5Kea8Q5Zdk2V3D1CaZqd99IdngPBeJ3nlFC9mXzdBKKn+N1m1uXb+yksTqPsh/3Tal5KKeBwJyIAr5qD/kvMzAVMolK+oni3oV51rPG7hbhJVc6oN0Vw5VRthWkY3b9wbjauHr"
}
