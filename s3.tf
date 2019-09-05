resource "aws_s3_bucket" "receiver" {
  bucket = var.receiver_bucket_name
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "ControlShift dumps CSVs here"
  }

  # expire the ingested CSVs 5 days after they have been processed to save disk space while providing enough
  # time to analyze things that might have gone wrong.
  lifecycle_rule {
    id      = "expire-csvs"
    enabled = true

    expiration {
      days = 5
    }
  }
}


resource "aws_s3_bucket" "manifest" {
  bucket = var.manifest_bucket_name
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "ControlShift puts import manifests here"
  }
}


