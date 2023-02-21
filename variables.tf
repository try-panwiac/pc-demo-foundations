#Define the variables used by the main terraform file
#owner: Alexandre Cezar

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc" {
  type = map(object({
    name        = string
    description = string
    cidr_block  = string
  }))
  default = {
    demo_foundations_vpc = {
      name        = "demo-foundations-vpc"
      description = "VPC for the foundations demo"
      cidr_block  = "172.20.0.0/20"
    }
  }
}

variable "public_subnet" {
  type = object({
    name = string
    cidr_block = string
  })
  default = {
    name = "public-subnet"
    cidr_block = "172.20.1.0/24"
  }
}

variable "internal_subnet" {
  type = object({
    name = string
    cidr_block = string
  })
  default = {
    name = "internal-subnet"
    cidr_block = "172.20.2.0/24"
  }
}

variable "vulnerable_ami" {
  type    = string
  default = "ami-0263e4deb427da90e" # Ubuntu 18.04 LTS in us-east-1
}

variable "vulnerable_instance_type" {
  type    = string
  default = "t2.small"
}

variable "bastion_ami" {
  type    = string
  default = "ami-0dfcb1ef8550277af" # Amazon Linux 2 LTS in us-east-1
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "internal_ami" {
  type    = string
  default = "ami-0dfcb1ef8550277af" # Amazon Linux 2 LTS in us-east-1
}

variable "internal_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key_name" {
type    = string
default = "demo-ssh"
}

variable "ssh_key_path" {
  type    = string
  default = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create"
  default = "pcdemo-cg-cardholder-data-bucket-xyz"
}

variable "folder_scripts" {
  type        = string
  description = "The path to the scripts folder"
  default = ""
}

variable "folder_assets" {
  type        = string
  description = "The path to the S3 bucket files folder"
  default = ""
}