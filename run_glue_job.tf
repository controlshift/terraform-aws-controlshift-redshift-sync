data "template_file" "run_glue_job_script" {
  template = file("${path.module}/templates/run-glue-job.js.tpl")

  vars = {
    glue_job_name = aws_glue_job.signatures_full.id
  }
}

data "archive_file" "run_glue_job_zip" {
  type        = "zip"

   source {
    content  = "${data.template_file.run_glue_job_script.rendered}"
    filename = "index.js"
  }

  output_path = "${path.module}/lambdas/run-glue-job.zip"
}

resource "aws_lambda_function" "glue_job_lambda" {
  filename = data.archive_file.run_glue_job_zip.output_path
  function_name = "controlshift-run-glue-job"
  role          = aws_iam_role.run_glue_job_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  timeout       = 60
  source_code_hash = filebase64sha256(data.archive_file.run_glue_job_zip.output_path)
}

resource "aws_cloudwatch_event_rule" "trigger_glue_job_on_crawler_finished" {
  name        = "trigger-glue-job-on-crawler-finished"
  description = "Trigger Lambda to start Glue job when crawler finishes successfully"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.glue"
  ],
  "detail-type": [
    "Glue Crawler State Change"
  ],
  "detail": {
    "state": [
      "Succeeded"
    ],
    "crawlerName": [
      "${aws_glue_crawler.signatures_crawler.name}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "trigger_run_glue_job_lambda" {
  rule      = aws_cloudwatch_event_rule.trigger_glue_job_on_crawler_finished.name
  target_id = "trigger-controlshift-run-glue-job"
  arn       = aws_lambda_function.glue_job_lambda.arn
}

resource "aws_lambda_permission" "allow_crawler_ran_cloudwatch_event" {
  function_name = aws_lambda_function.glue_job_lambda.function_name
  statement_id  = "AllowExecutionFromGlueCloudWatchEventOnCrawlerRan"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_glue_job_on_crawler_finished.arn
}
