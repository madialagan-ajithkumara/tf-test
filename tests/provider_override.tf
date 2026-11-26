# Used only by the AkOps check: fake credentials so terraform plan works without an AWS account.
provider "aws" {
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}
