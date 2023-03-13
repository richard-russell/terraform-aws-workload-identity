terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
    tfe = {
      version = ">= 0.42.0"
      source  = "hashicorp/tfe"
    }
    tls = {
      version = ">= 4.0.0"
      source  = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
