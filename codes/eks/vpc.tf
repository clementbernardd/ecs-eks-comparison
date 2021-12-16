# Creation of the VPC
resource "aws_vpc" "eks-tp3-vpc-terraform" {
  cidr_block           = var.vpcidr
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name
  tags = {
    Name = "Eks-tp3-VPC-terraform"
  }
}

# Creation of the subnets
resource "aws_subnet" "public_subnet" {
  count =  length(var.azs)
  availability_zone = element(var.azs,count.index)
  cidr_block = element(var.publicidr,count.index)
  vpc_id                  = aws_vpc.eks-tp3-vpc-terraform.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${count.index+1}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.eks-tp3-vpc-terraform.id
  tags = {
    Name = "Internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.eks-tp3-vpc-terraform.id
  route {
    # Enable subnet to reach internet
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.internet_gateway.id
  }
    tags            = {
      Name = "Route-table"
    }

}
resource "aws_route_table_association" "route_table_association" {
  count = length(aws_subnet.public_subnet.*.id)
  route_table_id = aws_route_table.route_table.id
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
}
