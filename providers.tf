terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    
  }
}

provider "docker" {}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_region" "current" {}