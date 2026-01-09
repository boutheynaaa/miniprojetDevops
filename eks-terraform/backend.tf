terraform {
  backend "s3" {
    bucket = "ml-terraform-state-8749f2b4"
    key    = "k8/terraform.tfstate"
    region = "us-east-1"
  }
}
