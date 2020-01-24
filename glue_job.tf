resource "aws_glue_catalog_database" "catalog_db" {
  name = "controlshift_${var.controlshift_environment}"
}

locals {
  signatures_s3_path = "s3://agra-data-exports-${var.controlshift_environment}/${var.controlshift_organization_slug}/full/signatures"
}

resource "aws_glue_crawler" "signatures_crawler" {
  database_name = aws_glue_catalog_database.catalog_db.name
  name = "${var.controlshift_environment}_full_signatures"
  role = aws_iam_role.glue_service_role.arn

  s3_target {
    path = local.signatures_s3_path
  }
}

resource "aws_s3_bucket" "glue_resources" {
  bucket = var.glue_scripts_bucket_name
  region = var.aws_region

  acl = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "template_file" "signatures_script" {
  template = file("${path.module}/templates/signatures_job.py.tpl")
  vars = {
    catalog_database_name = aws_glue_catalog_database.catalog_db.name
    redshift_database_name = var.redshift_database_name
  }
}

resource "aws_s3_bucket_object" "signatures_script" {
  bucket = aws_s3_bucket.glue_resources.id
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

resource "aws_iam_role_policy_attachment" "glue_resources" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "redshift_full_access" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy" "controlshift_data_export_bucket_access" {
  name = "AllowsCrossAccountAccessToControlShiftDataExportBucket"
  role = aws_iam_role.glue_service_role.id
  policy = data.aws_iam_policy_document.controlshift_data_export_bucket.json
}

# TODO: Use more restrictive permissions (?)
data "aws_iam_policy_document" "controlshift_data_export_bucket" {
  statement {
    effect = "Allow"
    actions = [ "s3:*" ]
    resources = [
      "arn:aws:s3:::agra-data-exports-${var.controlshift_environment}/${var.controlshift_organization_slug}/*"
    ]
  }
}

data "aws_subnet" "redshift_subnet" {
  id = var.redshift_subnet_id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_subnet.redshift_subnet.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_glue_connection" "redshift_connection" {
  name = "controlshift_${var.controlshift_environment}_data_sync"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${data.aws_redshift_cluster.sync_data_target.endpoint}:${data.aws_redshift_cluster.sync_data_target.port}/${var.redshift_database_name}"
    PASSWORD            = var.redshift_password
    USERNAME            = var.redshift_username
    JDBC_ENFORCE_SSL    = false
  }

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.redshift_subnet.availability_zone
    security_group_id_list = [ var.redshift_security_group_id ]
    subnet_id              = data.aws_subnet.redshift_subnet.id
  }
}

resource "aws_glue_job" "signatures_full" {
  name = "cs-${var.controlshift_environment}-signatures-full"
  connections = [ aws_glue_connection.redshift_connection.name ]
  glue_version = "1.0"
  default_arguments = {
    "--TempDir": "s3://${aws_s3_bucket.glue_resources.bucket}/${var.controlshift_environment}/temp",
    "--job-bookmark-option": "job-bookmark-disable",
    "--job-language": "python"
  }

  role_arn = aws_iam_role.glue_service_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.glue_resources.bucket}/${var.controlshift_environment}/signatures_job.py"
    python_version = "3"
  }
}
