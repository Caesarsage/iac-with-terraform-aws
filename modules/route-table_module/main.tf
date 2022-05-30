
#3 create route table
resource "aws_route_table" "production-rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0" // route to all network
    gateway_id = "${var.internet_gateway_id}"
  }

  route {
    ipv6_cidr_block  = "::/0"
    gateway_id       =  "${var.internet_gateway_id}"
  }

  tags = {
    Name = "production-rt"
  }
}