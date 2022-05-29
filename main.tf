provider "aws" {
  region     = var.aws_profile[0]
  access_key = var.aws_profile[1]
  secret_key = var.aws_profile[2]
}

variable "aws_profile" {
  description = " aws profile"
}

variable "aws_resource_profile" {
  description = "AWS resource profile"
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
  ingress = { 
    description = "HTTPS"
    from_port   = 443,
    to_port     = 443,
    protocol    = "tcp",
    cidr_blocks = ["0.0.0.0/0"]
  },
  ingress = {
    description = "HTTP",
    from_port   = 80,
    to_port     = 80,
    protocol    = "tcp",
    cidr_blocks = ["0.0.0.0/0"] 
  },

  ingress = {
    description = "SSH",
    from_port   = 22,
    to_port     = 22,
    protocol    = "tcp",
    cidr_blocks = ["0.0.0.0/0"] # allow for all
  },

  egress = {
    from_port   = 0,
    to_port     = 0,
    protocol    = "-1", # -1 is a special protocol that means all protocols
    cidr_blocks = ["0.0.0.0/0"]
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
