output "crawler_ecr_repository_url" {
  description = "The URL of the GovScout Crawler ECR repository"
  value       = aws_ecr_repository.govscout_crawler.repository_url
}
