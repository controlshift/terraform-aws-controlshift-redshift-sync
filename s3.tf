# Additional provider configuration for region your controlshift platform lives within.
provider "aws" {
  alias  = "controlshift"
  region = var.controlshift_aws_region
}

resource "aws_s3_bucket" "manifest" {
  provider = aws.controlshift
  bucket = var.manifest_bucket_name
  acl    = "private"
  region = var.controlshift_aws_region

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

  # expire the ingested manifests after 5 days after they have been processed to save disk space while providing enough
  # time to analyze things that might have gone wrong.
  lifecycle_rule {
    id      = "Remove temp files over a week old"
    abort_incomplete_multipart_upload_days = 0
    enabled = true
    prefix = "production/temp/"

    expiration {
      days = 7
      expired_object_delete_marker = false
    }
  }
}
