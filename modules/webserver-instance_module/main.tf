# 9 Creat unbuntus server 
# always specify similar availability_zone for neccesary resources
resource "aws_instance" "web-server" {
  ami = "${var.aws_resource_profile[0]}"
  instance_type = "${var.aws_resource_profile[1]}"
  availability_zone = "${var.aws_resource_profile[2]}"
  key_name = "${var.aws_resource_profile[3]}"

  network_interface {
    device_index = 0 
    network_interface_id = "${var.network_interface_id}"
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