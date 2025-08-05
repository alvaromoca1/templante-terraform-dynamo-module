terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  
  access_key                  = "test"        # cambios solo para localstack
  secret_key                  = "test"    # cambios solo para localstack  
  skip_credentials_validation = true          # cambios solo para localstack
  skip_metadata_api_check     = true          # cambios solo para localstack
  skip_requesting_account_id  = true          # cambios solo para localstack
  # Cambios para localstack
  endpoints {
    dynamodb = "http://localhost:4566" # Cambios para localstack
  }
}

module "module_dyn_example" {
  source = "./dyn-example"
}
