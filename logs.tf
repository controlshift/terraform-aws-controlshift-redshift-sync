resource "aws_cloudwatch_log_group" "loader" {
  name = "/aws/lambda/controlshift-redshift-loader${local.namespace_suffix_dashed}"
  retention_in_days = 5

  tags = {
    Application = "controlshift-redshift${local.namespace_suffix_dashed}"
  }
}

resource "aws_cloudwatch_log_group" "webhook" {
  name = "/aws/lambda/controlshift-webhook-handler${local.namespace_suffix_dashed}"
  retention_in_days = 5
  tags = {
    Application = "controlshift-redshift${local.namespace_suffix_dashed}"
  }
}
