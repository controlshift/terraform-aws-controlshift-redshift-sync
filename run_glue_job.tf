data "archive_file" "run_glue_job_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/run-glue-job.js"
  output_path = "${path.module}/lambdas/run-glue-job.zip"
}

resource "aws_lambda_function" "glue_lambda" {
  filename = data.archive_file.run_glue_job_zip.output_path
  function_name = "controlshift-run-glue-job"
  role          = aws_iam_role.receiver_lambda_role.arn
  handler       = "receiver.handler"
  runtime       = "nodejs10.x"
  timeout       = 60
  source_code_hash = filebase64sha256(data.archive_file.run_glue_job_zip.output_path)
}
