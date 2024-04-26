variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository"
}

variable "ecr_image_tag" {
  type        = string
  description = "The tag of the ECR image"
  default     = null
}
