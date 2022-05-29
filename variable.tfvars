subnet_profile = ["10.0.1.0/24", "10.0.2.0/24"]

aws_security_group = [
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow for all
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow for all
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow for all
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 is a special protocol that means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
]