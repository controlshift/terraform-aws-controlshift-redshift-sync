variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to use. Should match the location of your Redshift instance"
}

variable "redshift_cluster_identifier" {
  type = string
  description = "The target Redshift cluster ID"
}

variable "redshift_database_name" {
  type = string
}

variable "redshift_username" {
  type = string
}

variable "redshift_password" {
  type  = string
}

variable "redshift_schema" {
  type  = string
  default = "public"
  description = "The Redshift schema to load tables into"
}

variable "redshift_security_group_id" {
  type = string
  description = "The security group assigned to the Redshift cluster that will be used for connecting by Glue. For requirements on this Security Group see https://docs.aws.amazon.com/glue/latest/dg/setup-vpc-for-glue-access.html"
}

variable "manifest_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store manifests of ingests processed in"
}
variable "glue_scripts_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store Glue scripts in"
}
variable "manifest_prefix" {
  default = "manifests"
  type        = string
  description = "A file prefix that will be used for manifest logs on success"
}
variable "failed_manifest_prefix" {
  default = "failed"
  type        = string
  description = "A file prefix that will be used for manifest logs on failure"
}
variable "success_topic_name" {
  default = "ControlshiftLambdaLoaderSuccess"
  type        = string
  description = "An SNS topic name that will be notified about batch processing successes"
}
variable "failure_topic_name" {
  default = "ControlshiftLambdaLoaderFailure"
  type        = string
  description = "An SNS topic name that will be notified about batch processing failures"
}

variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
  type        = string
  description = "The hostname of your ControlShift instance. Likely to be something like action.myorganization.org"
}

variable "receiver_timeout" {
  default = 60
  type        = number
  description = "The timeout for the receiving Lambda, in seconds"
}

variable "controlshift_environment" {
  default = "production"
  type        = string
  description = "The environment of your ControlShift instance. Either staging or production"
}

variable "controlshift_organization_slug" {
  type = string
  description = "The organization's slug in ControlShift platform. Ask support team (support@controlshiftlabs.com) to find this value."
}