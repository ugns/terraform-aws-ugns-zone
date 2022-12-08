terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "ugns-use1-terraform-state"
    dynamodb_table = "ugns-use1-terraform-state-lock"
    profile        = ""
    role_arn       = "arn:aws:iam::465691465286:role/GitHubActionsExecution"
    encrypt        = "true"
  }
}
