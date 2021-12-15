provider "aws" {
  region  = var.region
  profile = "default"
}

data "aws_availability_zones" "azs" {
    state = "available"
}