#Secret S3 Bucket
resource "aws_s3_bucket" "pcdemo-cardholder-data-bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = var.s3_bucket_name
    Description = "S3 Bucket demo used for storing sensitive cardholder data."
  }
}

locals {
  asset_files = ["cardholder_data_primary.csv", "cardholder_data_secondary.csv", "cardholders_corporate.csv", "goat.png"]
}

resource "aws_s3_bucket_object" "s3_objects" {
  for_each = {for file in local.asset_files : file => file}

  bucket       = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  key          = "${var.folder_assets}/${each.key}"
  source       = "${var.folder_assets}/${each.key}"
  content_type = "text/plain"
}