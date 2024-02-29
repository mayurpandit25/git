terraform {
    backend "s3" {
        bucket = my-s3-bucket 
        key = terraform.tfstate
        region = ap-south-1
    }
}
provider "aws" {
    region = ap-south-1
  
}
resource "aws_isntance" "my-ec2" {
    ami = var.ami 
    instance_type = var.instance_type 
    key_name = var.key_pair
    tags = {
        name = "my-instance"
    }
    vpc_security_group_id = [place ur vpc here]
  
}

terraform {
    backend "s3" {
        bucket = my-s3-bucket 
        key = my-s3-bucket
        region = ap-south-1
    }
}
provider "aws" {
    region = ap-south-1
}
resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc-cidr 
    tags = {
        name = "${var.project}-vpc"
    }
}
resource "aws_subnet" "pub-subnet" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.pub-cidr 
    tags = {
        name = "${var.project}-pub-subnet"
    }
    availability_zone = var.pub-az 
}
resource "aws_subnet" "pvt-subnet" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.pvt-cidr 
    tags = {
        name = "${var.project}-pvt-subnet"
    }
    availability_zone = var.pvt-az
}
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id 
    tags = {
        name = "${var.project}-igw"
    }
}
resource "aws_default_route_table" "my-rt" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id

    route {
        cidr_block = 0.0.0.0/0
        gateway_id = aws_internet_gateway.my-igw.id 
    }
}

resource "aws_security_group" "my-sg" {
    name = "${var.project}-sg"
    region = ap-south-1
    vpc_id = aws_vpc.my-vpc.id 

    ingress {
        from_port = 80
        to_port = 80
        protocol = TCP 
        cidr_blocks = [0.0.0.0/0]
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = TCP 
        cidr_blocks = [0.0.0.0/0]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [0.0.0.0/0]
    }

    depends_on = [ aws_security_group ]
}
resource "aws_instance" "pub-instance" {
    ami = var.ami 
    instance_type = var.instance_type
    key_name = var.key_pair 
    tags = var.tags 
    subnet_id = aws_subnet.my-subnet.id 
    vpc_security_group_ids = aws_security_group.my-sg.id 

    user_data = <<-EOF 
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd.service
    echo "hello" > /var/www/html/index.html
    systemctl restart httpd.service
    systemctl enable httpd.service
    systemctl status httpd.service
    EOF 

    tags = {
        default {
            type = map 
            name = "my-instance" 
            env = devops
        }
    }
  
}
resource "aws_instance" "pvt-isntanc" {
    ami = var.ami 
    isntance_type = var.instance_type 
    key_name = var.key_pair 
    subnet_id = aws_subnet.pvt-subnet.id 
    tags = var.tags
    vpc_security_group_ids = aws_security_group.my-sg.id 

  
}

variable "isntace_Type" {
    default = t2.micro
}
variable "key_name" {
    default = id_rsa   
}
variable "vpc-cidr" {
    default = 10.0.0.0/6
}
variable "pub-cidr" {
    default = 10.0.1.0/24
}
variable "pvt-cidr" {
    default = 10.0.2.0/24
}
variable "pub-az" {
    default = ap-south-1a
}
variable "pvt-az" {
    default = ap-south-1b
}
variable "instance_id" {
    default = niuhrgrhgurgh
}
variable "region" {
    default = ap-south-1
}
variable "project" {
    default = cloudblitz
}

output "public_ip" {
    value = aws_instance.pub-instance.public_ip
}
