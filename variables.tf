#Define the variables used by the different terraform files
#owner: Alexandre Cezar

#Controls the deployment region
variable "region" {
  type    = string
  default = "us-east-1"
}
#VPC naming, description and CIDR configuration
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

#Public Subnet naming and CIDR configuration
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

#Internal Subnet naming and CIDR configuration
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

#AMI ID that is going to be used by the vulnerable instance (region dependent)
variable "vulnerable_ami" {
  type    = string
  default = "ami-0263e4deb427da90e" # Ubuntu 18.04 LTS in us-east-1
}

#Instance type that is going to be used by the vulnerable instance
variable "vulnerable_instance_type" {
  type    = string
  default = "t2.small"
}

#AMI ID that is going to be used by the bastion instance (region dependent)
variable "bastion_ami" {
  type    = string
  default = "ami-0dfcb1ef8550277af" # Amazon Linux 2 LTS in us-east-1
}

#Instance type that is going to be used by the bastion instance
variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

#AMI ID that is going to be used by the internal instance (region dependent)
variable "internal_ami" {
  type    = string
  default = "ami-0dfcb1ef8550277af" # Amazon Linux 2 LTS in us-east-1
}

#Instance type that is going to be used by the insternal instance
variable "internal_instance_type" {
  type    = string
  default = "t2.micro"
}

#SSH Key that is going to be associated with the instances during deployment
variable "ssh_key_name" {
type    = string
default = "demo-ssh"
}

#The path for the SSH key - It has to be locally accessible by the tf plan
variable "ssh_key_path" {
  type    = string
  default = ""
}

#Name of the S3 bucket that is going to be created
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create"
  default = "pcdemo-cg-cardholder-data-bucket-xyz"
}

#Path to the scripts folder (scripts that automate the configuration of the vulnerable instance)
variable "folder_scripts" {
  type        = string
  description = "The path to the scripts folder"
  default = ""
}

#Path to the assets folder (files that are stored in the S3 bucket for the Data Security demo)
variable "folder_assets" {
  type        = string
  description = "The path to the S3 bucket files folder"
  default = ""
}