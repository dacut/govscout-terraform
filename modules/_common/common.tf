# Common variables and locals for all modules.

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "environment" {
  description = "The environment in which the resources will be created"
  type        = string
}

variable "partition" {
  description = "The AWS partition in which the resources will be created"
  type        = string
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The region in which the resources will be created"
  type        = string
}

locals {
  account_id        = var.account_id
  environment       = var.environment
  environment_lower = lower(var.environment)
  partition         = var.partition
  project           = var.project
  project_lower     = lower(var.project)
  region            = var.region
}
