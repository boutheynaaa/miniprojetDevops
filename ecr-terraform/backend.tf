terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.25.0"
    }
  }
 
  backend "s3" {
    bucket = "ml-terraform-state-8749f2b4"  # ← Changé ici
    key    = "ecr/terraform.tfstate"
    region = "us-east-1"
  }
 
  required_version = ">= 1.6.3"
}
