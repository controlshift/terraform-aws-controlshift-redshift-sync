resource "aws_dynamodb_table" "processed_files" {
  name  = "LambdaRedshiftProcessedFiles"
  billing_mode = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 5

  attribute {
    name = "loadFile"
    type = "S"
  }

  hash_key = "loadFile"
}
