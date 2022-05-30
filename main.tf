variable "aws_profile" {}
variable "aws_resource_profile" {}

provider "aws" {
  region     = "${var.aws_profile[0]}"
  access_key = "${var.aws_profile[1]}"
  secret_key = "${var.aws_profile[2]}"
}

# Import modules
module "vpc" {
  source = "./modules/vpc_module"
}
module "internet-gateway" {
  source = "./modules/internet-gateway_module"
  vpc_id = "${module.vpc.vpc_id}"
}
module "route-table" {
  source = "./modules/route-table_module"
  vpc_id = "${module.vpc.vpc_id}" 
  internet_gateway_id = "${module.internet-gateway.internet_gateway_id}"
}
module "subnet" {
  source = "./modules/subnet_module"
  vpc_id = "${module.vpc.vpc_id}"
  route_table_id = "${module.route-table.route_table_id}"
}
module "security-groups" {
  source = "./modules/security-group_module"
  vpc_id = "${module.vpc.vpc_id}"
}
module "network-interface" {
  source = "./modules/network-interface_module"
  subnet_id = "${module.subnet.subnet_id}"
  security_groups = "${module.security-groups.security_group_id}"
}
module "elastic-ip" {
  source = "./modules/elastic-ip_module"
  internet_gateway_id = "${module.internet-gateway.internet_gateway_id}"
  network_interface_id = "${module.network-interface.network_interface_id}"
}
module "webserver-intance" {
  source = "./modules/webserver-instance_module"
  network_interface_id = "${module.network-interface.network_interface_id}"
  aws_resource_profile = "${var.aws_resource_profile}"
}