resource "aws_s3_bucket" "glue_script" {
  bucket = var.glue_scripts_bucket_name
}

data "template_file" "signatures_script" {
  template = file("${path.module}/templates/signatures_job.py.tpl")
  vars = {}
}

resource "aws_s3_bucket_object" "signatures_script" {
  bucket = aws_s3_bucket.glue_script.id
  key = "${var.controlshift_environment}/signatures_job.py"
  acl = "private"

  content = data.template_file.signatures_script.rendered
}

resource "aws_iam_role" "glue_service_role" {
  name = "AWSGlueServiceRole"
  description = "Used by the AWS Glue jobs to insert data into redshift"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# TODO: give glue_service_role some permissions as currently held by
#       AWSGlueServiceRole-ManualTest

resource "aws_glue_job" "signatures_full" {
  name = "cs-${var.controlshift_environment}-signatures-full"

  role_arn = aws_iam_role.glue_service_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.glue_script.bucket}/${var.controlshift_environment}/signatures_job.py"
  }
}
