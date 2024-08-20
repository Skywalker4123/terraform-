provider "aws" {
  region = "us-east-1"
}

# vpc 

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MY_VPC"
  }
}

# public subnets

resource "aws_subnet" "Public_Subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.10.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_public_subnet-${count.index}"
  }
}

# private subnets

resource "aws_subnet" "Private_Subnet" {
  count      = 2
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.10.${count.index + 10}.0/24"

  tags = {
    Name = "my_private_subnet-${count.index}"
  }
}


# internet gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My_IGW"
  }
}

# route table for public subnet

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    gateway_id = aws_internet_gateway.my_igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "Public_Route_Table"
  }
}

# Associate public subnets with the public route table

resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.Public_Subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# route table for private subnet

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private_Route_Table"
  }
}

# Associate private subnets with their respective route tables

resource "aws_route_table_association" "Private_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.Private_Subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "my_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
