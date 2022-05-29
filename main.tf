provider "aws" {
  region     = var.aws_profile[0].region
  access_key = var.aws_profile[0].access_key
  secret_key = var.aws_profile[0].secret_key
}

variable "aws_profile" {
  description = " aws profile"
}

variable "aws_resource_profile" {
  description = "AWS resource profile"
}

variable "aws_security_group" {
  description = "AWS security group"
} 

variable "subnet_profile" {
  description = "cidr block  and name for profile" 
}

#1 create a VPC
resource "aws_vpc" "production-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

#2 Create a gateway - must come first before elastic ip creation
resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production-vpc.id
  tags   = {
    Name = "production-igw"
  }
}

#3 create route table
resource "aws_route_table" "production-rt" {
  vpc_id = aws_vpc.production-vpc.id

  route {
    cidr_block = "0.0.0.0/0" // route to all network
    gateway_id = aws_internet_gateway.production-igw.id
  }

  route {
    ipv6_cidr_block  = "::/0"
    gateway_id       =  aws_internet_gateway.production-igw.id
  }

  tags = {
    Name = "production-rt"
  }
}

#4 create subnet for web server vpc
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.production-vpc.id
  cidr_block = var.subnet_profile[0]
  availability_zone = "us-east-1a"
  tags = {
    Name = "production-subnet-1"
  }
}

#4b create subnet for web server vpc
resource "aws_subnet" "subnet-2" {
  vpc_id = aws_vpc.production-vpc.id
  cidr_block = var.subnet_profile[1]
  availability_zone = "us-east-1a"
  tags = {
    Name = "development-subnet-2"
  }
}

#5 assign subnet to the route table
resource "aws_route_table_association" "subnet-1-association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.production-rt.id
}

# create a security group
resource "aws_security_group" "allow-web-security-group" {
  vpc_id = aws_vpc.production-vpc.id
  description = "Allow web inbound traffic"
  name = "allows_web_traffic"
  ingress {
    description = var.aws_security_group[0].description
    from_port   = var.aws_security_group[0].from_port
    to_port     = var.aws_security_group[0].to_port
    protocol    = var.aws_security_group[0].protocol
    cidr_blocks = var.aws_security_group[0].cidr_blocks
  }
  ingress {
    description = var.aws_security_group[1].description
    from_port   = var.aws_security_group[1].from_port
    to_port     = var.aws_security_group[1].to_port
    protocol    = var.aws_security_group[1].protocol
    cidr_blocks = var.aws_security_group[1].cidr_blocks
  }
  ingress {
    description = var.aws_security_group[2].description
    from_port   = var.aws_security_group[2].from_port
    to_port     = var.aws_security_group[2].to_port
    protocol    = var.aws_security_group[2].protocol
    cidr_blocks = var.aws_security_group[2].cidr_blocks
  }
  egress {
    from_port   = var.aws_security_group[3].from_port
    to_port     = var.aws_security_group[3].to_port
    protocol    = var.aws_security_group[3].protocol
    cidr_blocks = var.aws_security_group[3].cidr_blocks
  }

  tags = {
    Name = "allow-web"
  }
}

#7 Create network interface
resource "aws_network_interface" "web-server-network-interface" {
  subnet_id = aws_subnet.subnet-1.id
  private_ips = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web-security-group.id]
}

#8 Create aws elastic ip
resource "aws_eip" "eip" {
  vpc = true
  network_interface = aws_network_interface.web-server-network-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.production-igw]
}

# 9 Creat unbuntus server 
# always specify similar availability_zone for neccesary resources
resource "aws_instance" "web-server" {
  ami = var.aws_resource_profile[0]
  instance_type = var.aws_resource_profile[1]
  availability_zone = var.aws_resource_profile[2]
  key_name = var.aws_resource_profile[3]

  
  network_interface {
    device_index = 0 
    network_interface_id = aws_network_interface.web-server-network-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash 
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo my first web server > /var/www/html/index.html'              
            EOF
            
  tags = {
    Name = "web-server"
  }
}
