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
  cloud {
    organization = "richard-russell-org"
    workspaces {
      name = "aws_dynamic_creds"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.aws_default_tags
  }
}
