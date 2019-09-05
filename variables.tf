variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to use. Should match the location of your Redshift instance"
}

variable "redshift_database_name" {
  type = string
}

variable "redshift_dns_name" {
  type = string
}

variable "redshift_port" {
  type = string
}

variable "redshift_username" {
  type = string
}

variable "redshift_password" {
  type  = string
}

variable "receiver_bucket_name" {
  type        = string
  description = "Your S3 bucket name ingest CSVs will be stored in"
}
variable "manifest_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store manifests of ingests processed in"
}
variable "manifest_prefix" {
  default = "manifests/"
  type        = string
  description = "A file prefix that will be used for manifest logs on success"
}
variable "failed_manifest_prefix" {
  default = "failed/"
  type        = string
  description = "A file prefix that will be used for manifest logs on failure"
}

variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
  type        = string
  description = "The hostname of your ControlShift instance. Likely to be something like action.myorganization.org"
}
