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

resource "aws_sns_topic" "glue_job_success" {
  depends_on = [ aws_glue_job.signatures_full ]
  name = var.success_topic_name_for_run_glue_job_lambda
  policy = data.aws_iam_policy_document.sns_notification_policy_for_successful_run_glue_job.json
}

data "aws_iam_policy_document" "sns_notification_policy_for_successful_run_glue_job" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "events.amazonaws.com" ]
    }
    actions = [
      "SNS:Publish"
    ]
    resources = [
      "arn:aws:sns:*:*:${var.success_topic_name_for_run_glue_job_lambda}"
    ]
  }
}

resource "aws_cloudwatch_event_rule" "successful_glue_job_run" {
  name        = "successful-glue-job-run"
  description = "Glue Job finished successfully"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.glue"
  ],
  "detail-type": [
    "Glue Job State Change"
  ],
  "detail": {
    "state": [
      "SUCCEEDED"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "notify_successful_glue_job" {
  rule      = aws_cloudwatch_event_rule.successful_glue_job_run.name
  target_id = "notify-successful-glue-job-run"
  arn       = aws_sns_topic.glue_job_success.arn
}

resource "aws_sns_topic" "glue_job_failure" {
  depends_on = [ aws_glue_job.signatures_full ]
  name = var.failure_topic_name_for_run_glue_job_lambda
  policy = data.aws_iam_policy_document.sns_notification_policy_for_failed_run_glue_job.json
}

data "aws_iam_policy_document" "sns_notification_policy_for_failed_run_glue_job" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "events.amazonaws.com" ]
    }
    actions = [
      "SNS:Publish"
    ]
    resources = [
      "arn:aws:sns:*:*:${var.failure_topic_name_for_run_glue_job_lambda}"
    ]
  }
}

resource "aws_cloudwatch_event_rule" "failed_glue_job_run" {
  name        = "failed-glue-job-run"
  description = "Glue Job finished with failure"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.glue"
  ],
  "detail-type": [
    "Glue Job State Change"
  ],
  "detail": {
    "state": [
      "FAILED", "TIMEOUT"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "notify_failed_glue_job" {
  rule      = aws_cloudwatch_event_rule.failed_glue_job_run.name
  target_id = "notify-failed-glue-job-run"
  arn       = aws_sns_topic.glue_job_failure.arn
}
