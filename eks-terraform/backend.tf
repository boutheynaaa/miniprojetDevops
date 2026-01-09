terraform {
  backend "s3" {
    bucket = "my-terraform-state-boutheyna"
    key    = "k8/terraform.tfstate"
    region = "us-east-1"
  }
}

