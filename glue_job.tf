resource "aws_glue_catalog_database" "catalog_db" {
  name = "controlshift_${var.controlshift_environment}"
}

locals {
  # TODO: "default" here needs to be the org slug, but we don't have a variable for that yet
  signatures_s3_path = "s3://agra-data-exports-${var.controlshift_environment}/default/full/signatures"
}

resource "aws_glue_catalog_table" "signatures" {
  name = "signatures"
  database_name = aws_glue_catalog_database.catalog_db.name

  storage_descriptor {
    location = local.signatures_s3_path
  }
}

resource "aws_glue_crawler" "signatures_crawler" {
  database_name = aws_glue_catalog_database.catalog_db.name
  name = "${var.controlshift_environment}_full_signatures"
  role = aws_iam_role.glue_service_role.arn

  s3_target {
    path = local.signatures_s3_path
  }
}

resource "aws_s3_bucket" "glue_script" {
  bucket = var.glue_scripts_bucket_name
}

data "template_file" "signatures_script" {
  template = file("${path.module}/templates/signatures_job.py.tpl")
  vars = {
    database_name = aws_glue_catalog_database.catalog_db.name
  }
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
