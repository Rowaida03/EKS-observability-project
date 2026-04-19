resource "aws_ecr_repository" "game_2048" {
  name                 = "game-2048"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Owner        = "Rowaida"
    Environment = "dev"
    Project     = "eks-observability-project"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.game_2048.repository_url
}