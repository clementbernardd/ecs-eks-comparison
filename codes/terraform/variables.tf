variable "region" {
  default     = "us-east-1"
  description = "Region where are created the objects"
}

variable "azs" {
  description = "Availability zones"
  type = list
  default = ["us-east-1a","us-east-1b"]

}

variable "vpcidr" {
  description = "Cidr block for VPC"
  type = string
  default = "192.168.0.0/25"
}


variable "publicidr" {
  description = "Cidr blocks for public subnets"
  type = list
  default = ["192.168.0.64/27","192.168.0.96/27"]

}