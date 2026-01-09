terraform {
  backend "s3" {
    bucket = "ml-terraform-state-boutheyna"
    key    = "s3-buckets/terraform.tfstate"
    region = "us-east-1"
  }
}
