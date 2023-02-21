#Sets the required providers and versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}

# Passes the region where all the region based resources are going to be created
provider "aws" {
  region = var.region
}