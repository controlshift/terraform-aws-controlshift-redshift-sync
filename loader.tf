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

resource "aws_s3_bucket_notification" "notifications" {
  bucket = aws_s3_bucket.receiver.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incremental"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "full"
  }
}

resource "aws_sns_topic" "success_sns_topic" {
  name = var.success_topic_name

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${var.success_topic_name}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_lambda_function.loader.arn}"}
        }
    }]
}
POLICY
}

resource "aws_sns_topic" "failure_sns_topic" {
  name = var.failure_topic_name

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${var.failure_topic_name}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_lambda_function.loader.arn}"}
        }
    }]
}
POLICY
}
