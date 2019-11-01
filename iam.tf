data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "receiver_lambda_role" {
  name = "ReceiverLambdaRole"
  description = "Used by the controlshift-webhook-handler Lambda for receiving db replication data from ControlShift"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "processor_lambda_role" {
  name = "ProcessorLambdaRole"
  description = "Used by the controlshift-processor Lambda for writing table data into s3"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "receiver_execution_policy" {
  # allow the lambda to write cloudwatch logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # allow the lambda to enqueue work
  statement {
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${var.aws_region}:*:${aws_sqs_queue.receiver_queue.name}"]
  }
}

data "aws_iam_policy_document" "processor_execution_policy" {
  # allow the lambda to write cloudwatch logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # allow the lambda to put files into the receiver bucket
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.receiver.bucket}/*"]
  }

  statement {
    effect = "Allow"
    actions = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = ["arn:aws:sqs:${var.aws_region}:*:${aws_sqs_queue.receiver_queue.name}"]
  }
}

resource "aws_iam_role_policy" "lambda_receiver" {
  name = "AllowsReceiverExecution"
  role = aws_iam_role.receiver_lambda_role.id
  policy = data.aws_iam_policy_document.receiver_execution_policy.json
}

resource "aws_iam_role_policy" "lambda_processor" {
  name = "AllowsProcessorExecution"
  role = aws_iam_role.processor_lambda_role.id
  policy = data.aws_iam_policy_document.processor_execution_policy.json
}

resource "aws_iam_role" "api_gateway_role" {
  name = "APIGatewayRole"
  description = "Used by the Controlshift API Gateway webhook endpoint for CloudWatch logging"
  assume_role_policy = data.aws_iam_policy_document.gateway_assume_role.json
}

data "aws_iam_policy_document" "gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "gateway_cloudwatch_logging" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role" "loader_lambda_role" {
  name = "LoaderLambdaRole"
  description = "Used by the controlshift-redshift-loader Lambda for processing db replication data from ControlShift into Redshift"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_loads_tables" {
  name = "AllowsLoaderExecution"
  role = aws_iam_role.loader_lambda_role.id
  policy = data.aws_iam_policy_document.loader_execution_policy.json
}

data "aws_iam_policy_document" "loader_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTables",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.loader_config.arn,
      aws_dynamodb_table.batches.arn,
      aws_dynamodb_table.processed_files.arn
    ]
  }

  # Apparently, the KMS resource needs to be *
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:List*",
    ]
    resources = [
      aws_s3_bucket.receiver.arn,
      aws_s3_bucket.manifest.arn,
      "${aws_s3_bucket.receiver.arn}/*",
      "${aws_s3_bucket.manifest.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:GetEndpointAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:GetTopicAttributes",
      "sns:ListTopics",
      "sns:Publish",
      "sns:Subscribe",
      "sns:Unsubscribe"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
