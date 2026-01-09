provider "aws" {
  region = "us-east-1"  # Change as needed
}

locals {
  services = [
    "productservice",
    "orderservice",
    "inventoryservice",
    "gatewayservice",
    "paymentservice",
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.services)

  name = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  # ✅ This line tells AWS to delete all images before deleting the repo
  force_delete = true

  tags = {
    Environment = "production"
    Service     = each.value
  }
}
