resource "aws_cloudwatch_log_group" "loader" {
  name = "/aws/lambda/controlshift-redshift-loader"
  retention_in_days = 5

  tags = {
    Application = "controlshift-redshift"
  }
}

resource "aws_cloudwatch_log_group" "webhook" {
  name = "/aws/lambda/controlshift-webhook-handler"
  retention_in_days = 5
  tags = {
    Application = "controlshift-redshift"
  }
}

resource "aws_cloudwatch_log_group" "invoker" {
  name = "/aws/lambda/controlshift-webhook-handler-invoker"
  retention_in_days = 5
  tags = {
    Application = "controlshift-redshift"
  }
}
