terraform {
  backend "s3" {
    bucket = "ml-terraform-state-ff024e5a"
    key    = "k8/terraform.tfstate"
    region = "us-east-1"
  }
}

