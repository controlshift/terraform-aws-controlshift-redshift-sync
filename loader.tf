resource "aws_lambda_function" "loader" {
  s3_bucket = "awslabs-code-${var.aws_region}"
  s3_key = "LambdaRedshiftLoader/AWSLambdaRedshiftLoader-2.7.0.zip"
  function_name = "controlshift-redshift-loader"
  role          = aws_iam_role.loader_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs8.10"
  timeout       = 300
  environment {
    variables = {
      "DEBUG" = "true"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.loader.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.receiver.arn
}

resource "aws_s3_bucket_notification" "full_notification" {
  bucket = aws_s3_bucket.receiver.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "full"
  }
}

resource "aws_s3_bucket_notification" "incremental_notification" {
  bucket = aws_s3_bucket.receiver.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incremental"
  }
}
