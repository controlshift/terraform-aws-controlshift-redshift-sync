resource "aws_s3_bucket" "glue_script" {
  # TODO
  bucket = "aws-glue-scripts-087959666724-us-west-1"
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

resource "aws_glue_job" "signatures_full" {
  name = "cs-${var.controlshift_environment}-signatures-full"

  # TODO
  role_arn = "arn:aws:iam::087959666724:role/service-role/AWSGlueServiceRole-ManualTest"

  command {
    script_location = "s3://${aws_s3_bucket.glue_script.bucket}/${var.controlshift_environment}/signatures_job.py"
  }
}
