terraform {
  backend "s3" {
    bucket = "my-terraform-state-boutheyna"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
    
    # Disable features that require additional S3 permissions
    # These are blocked in AWS Academy
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = false
  }
}
