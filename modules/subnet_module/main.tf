
#4 create subnet for web server vpc
resource "aws_subnet" "subnet-1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "production-subnet-1"
  }
}

#5 assign subnet to the route table
resource "aws_route_table_association" "subnet-1-association" {
  subnet_id      = "${aws_subnet.subnet-1.id}"
  route_table_id = "${var.route_table_id}"
}