terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::072105303426:role/GitHubActionsExecution"
  }
}