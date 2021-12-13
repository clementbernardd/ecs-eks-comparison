variable "region" {
    default = "us-east-1"
}
data "aws_availability_zones" "available" {}

variable "vpcidr" {
    default = "10.0.0.0/16"
}

variable "subnetid" {
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}