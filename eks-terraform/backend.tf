terraform {
  backend "s3" {
    bucket = "ml-terraform-state-8749f2b4"
    key    = "s3-buckets/terraform.tfstate"
    region = "us-east-1"
  }
}
