# Defines the required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

# Defines the region where the deployment is going to take place
provider "aws" {
  region = var.region
}