#Creates S3 buckets for CSPM and Data Security
#owner: Alexandre Cezar

#Creates a private S3 bucket using the variable set up in the vars.tf file
resource "aws_s3_bucket" "pcdemo-cardholder-data-bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = var.s3_bucket_name
    Description = "S3 Bucket demo used for storing sensitive cardholder data."
  }
}


resource "aws_s3_bucket_versioning" "pcdemo-cardholder-data-bucket" {
  bucket = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name = "aws-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_replication_configuration" "pcdemo-cardholder-data-bucket" {
  depends_on = [aws_s3_bucket_versioning.pcdemo-cardholder-data-bucket]
  role   = aws_iam_role.pcdemo-cardholder-data-bucket.arn
  bucket = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  rule {
    id = "foobar"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}


#Creates a public S3 bucket using the variable set up in the vars.tf file
resource "aws_s3_bucket" "pcdemo-public_bucket" {
  bucket = var.s3_public_bucket_name
  acl    = "public-read"
  force_destroy = true
  tags = {
    Name        = var.s3_public_bucket_name
    Description = "S3 PublicBucket demo used for storing malware."
  }
}


resource "aws_s3_bucket_versioning" "pcdemo-public_bucket" {
  bucket = aws_s3_bucket.pcdemo-public_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = aws_s3_bucket.pcdemo-public_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name = "aws-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_replication_configuration" "pcdemo-public_bucket" {
  depends_on = [aws_s3_bucket_versioning.pcdemo-public_bucket]
  role   = aws_iam_role.pcdemo-public_bucket.arn
  bucket = aws_s3_bucket.pcdemo-public_bucket.id
  rule {
    id = "foobar"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}


#Defines the files that are going to be upload to the private S3 bucket (could be a variable as well, but as these are hardcoded for now, I saw no need)
locals {
  private_files = ["cardholder_data_primary.csv", "cardholder_data_secondary.csv", "cardholders_corporate.csv", "goat.png"]
}

#Loops through files to make sure they're all uploaded properly
#It uses the folder_assets variable for file disk location

resource "aws_s3_bucket_object" "s3_objects" {
  for_each = {for file in local.private_files : file => file}

  bucket       = aws_s3_bucket.pcdemo-cardholder-data-bucket.id
  key          = "${var.folder_assets}/${each.key}"
  source       = "${var.folder_assets}/${each.key}"
  content_type = "text/plain"
}

#Defines the files that are going to be upload to the public S3 bucket (could be a variable as well, but as these are hardcoded for now, I saw no need)
locals {
  public_files = ["wildfire-test-pe-file.exe"]
}

#Loops through files to make sure they're all uploaded properly.
#It uses the folder_assets variable for file disk location

resource "aws_s3_bucket_object" "s3_public_objects" {
  for_each = {for file in local.public_files : file => file}

  bucket       = aws_s3_bucket.pcdemo-public_bucket.id
  key          = "${var.folder_assets}/${each.key}"
  source       = "${var.folder_assets}/${each.key}"
  content_type = "text/plain"
}
