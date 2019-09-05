resource "aws_dynamodb_table" "batches" {
  name  = "LambdaRedshiftBatches"
  billing_mode = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 5

  attribute {
    name = "batchId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "s3Prefix"
    type = "S"
  }

  attribute {
    name = "lastUpdate"
    type = "N"
  }

  hash_key = "s3Prefix"
  range_key = "batchId"

  global_secondary_index {
    name = "LambdaRedshiftBatchStatus"
    hash_key = "status"
    range_key = "lastUpdate"
    projection_type = "ALL"
    read_capacity  = 1
    write_capacity = 5
  }
}
