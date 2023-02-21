#Creates the S3 bucket using the variable set up in the vars.tf file
resource "aws_s3_bucket" "pcdemo-cardholder-data-bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = var.s3_bucket_name
    Description = "S3 Bucket demo used for storing sensitive cardholder data."
  }
}

#Defines the files that are going to be upload to the S3 bucket (could be a variable as well, but as these are hardcoded for now, I saw no need)
locals {
  asset_files = ["cardholder_data_primary.csv", "cardholder_data_secondary.csv", "cardholders_corporate.csv", "goat.png"]
}

#Loops through files to make sure they're all uploaded properly (could be a variable as well, but as these are hardcoded
#for now, I saw no need to another set of variables).
#It uses the folder_assets variable for file disk location

resource "aws_s3_bucket_object" "s3_objects" {
  for_each = {for file in local.asset_files : file => file}

  bucket       = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  key          = "${var.folder_assets}/${each.key}"
  source       = "${var.folder_assets}/${each.key}"
  content_type = "text/plain"
}