
#2 Create a gateway - must come first before elastic ip creation
resource "aws_internet_gateway" "production-igw" {
  vpc_id = "${var.vpc_id}"
  tags   = {
    Name = "production-igw"
  }
}