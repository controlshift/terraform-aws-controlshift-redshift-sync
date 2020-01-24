data "template_file" "run_glue_crawler_script" {
  template = file("${path.module}/templates/run-glue-crawler.js.tpl")

  vars = {
    glue_crawler_name = aws_glue_crawler.signatures_crawler.name
  }
}

data "archive_file" "run_glue_crawler_zip" {
  type        = "zip"

   source {
    content  = "${data.template_file.run_glue_crawler_script.rendered}"
    filename = "index.js"
  }

  output_path = "${path.module}/lambdas/run-glue-crawler.zip"
}

resource "aws_lambda_function" "glue_crawler_lambda" {
  filename = data.archive_file.run_glue_crawler_zip.output_path
  function_name = "controlshift-run-glue-crawler"
  role          = aws_iam_role.run_glue_crawler_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  timeout       = 60
  source_code_hash = filebase64sha256(data.archive_file.run_glue_crawler_zip.output_path)
}

resource "aws_lambda_event_source_mapping" "run_crawler_on_new_data_export_task" {
  event_source_arn = aws_sqs_queue.receiver_queue.arn
  function_name    = aws_lambda_function.glue_crawler_lambda.arn
  batch_size = 1
}