data "archive_file" "process_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/process.js"
  output_path = "${path.module}/lambdas/process.zip"
}

resource "aws_lambda_function" "process_lambda" {
  filename = data.archive_file.process_zip.output_path
  function_name = "controlshift-queue-processor"
  role          = aws_iam_role.processor_lambda_role.arn
  handler       = "process.handler"
  runtime       = "nodejs10.x"
  timeout       = 900
  source_code_hash = filebase64sha256(data.archive_file.process_zip.output_path)

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.receiver.bucket
    }
  }
}

resource "aws_lambda_event_source_mapping" "process_task" {
  event_source_arn = aws_sqs_queue.receiver_queue.arn
  function_name    = aws_lambda_function.process_lambda.arn
}
