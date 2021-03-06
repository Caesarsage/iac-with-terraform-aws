# Ubuntu and apache2 instance on aws with terraform

## Steps

- Create VPC
- Create Internet gateway
- Create custom route table
- Create a subnet
- Associate subnet with route table
- Create Security Group to allow port 22, 80, 443
- Create a network interface with an IP in the subnet that was created in step 4
- Assign an elastic ip to the the network interface created in 7
- Create Ubuntu and Install apache

## Initial and prerequisite

- Setup aws cloud account
- Get access key and secret key credentials
## Setup and run instance

Set up terraform environment

```
terraform init
terraform plan -var-file secret.tfvars
terraform apply -var-file secret.tfvars
```

### View EC2 instance created in your aws account

<img src="assets/aws-console.jpg" alt="aws-console" />

### Click on instance _web-server_ just created and you can either access the apache2 sever through

- Public Ip
- SSH

<img src="assets/live.jpg" alt="web" />

## Clean up : Destroy instance

```
  terraform destroy -var-file secret.tfvars
```
