terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "first" {
  bucket = "${var.bucket_prefix}-${random_id.bucket_id.hex}"
  acl    = "private"

  tags = {
    Name      = var.bucket_prefix
    CreatedBy = "jenkins-terraform"
  }
}
