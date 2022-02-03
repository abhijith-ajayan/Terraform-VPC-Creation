# Terraform Script to create VPC

Using this Script i'm creating a VPC with 6 subnets(3 public and 3 private) along with an Internet Gateway, a NAT Gateway and 2 Route Tables(1 public and 1 private). Also, a Bastion server(having only SSH access), a webserver(HTTP and HTTPS port enabled and also SSH access from the bastion server) and a database server(with 3306 port and SSH access from bastion server)

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

# Architecture

![](https://i.ibb.co/ZcCRxGJ/68747470733a2f2f692e6962622e636f2f73777a4a4a726e2f7670632e706e67.png)

# Terraform

Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files

## Installing Terraform

- Create a directory where you can create terraform configuration files.
- Download Terrafom, click here [Terraform](https://www.terraform.io/downloads.html)
- Install Terraform, click here [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

#### Command line steps to install Terraform

```sh
# wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
# unzip terraform_1.0.8_linux_amd64.zip
# mv terraform /usr/local/bin/

# terraform version   =======> To check the version
Terraform v1.0.8
on linux_amd64
```

## Prerequisites

- Create an IAM user on your AWS console that have access to create the required resources.
- Create a dedicated directory where you can create terraform configuration files.
- Create a key pair using ssh-keygen command and save the files in this terraform directory



## 1. Configuring Provider file

```sh
vim provider.tf
```

```
provider "aws" {
  region = "ap-south-1"	
}
```

> Since we have attached IAM Role we don't need to give the access key and secret key in the file, for further details please check this link [provider](https://www.terraform.io/language/providers/configuration).

## 2. Variable Declaration
```sh
vim variables.tf
```
> please use the below content in variables file

```
variable "env" {
	
  default = "dev"
}

variable "project" {
	
  default = "zomato"	
}

variable "region" {
  
  default = "ap-south-1"	

}

variable "vpc_cidr" {
  
  default = "172.16.0.0/16"	

}

variable "type" {
  default = "t2.micro"
}

```

## 3. Fetching Availability Zones and AMI id data

```sh
vim sourcefile.tf
```
> using the below code we will get the latest amazon linux ami and availablility zone details in the current AWS Region, you can refer this link for getting more details [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) .
```
data "aws_ami" "amiimage" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_availability_zones" "myAZ" {

  state = "available"

}

```

## 3. Creation of VPC


```sh
vim main.tf
```

### VPC Creation
```
#======================================
# VPC Creation
#======================================

resource "aws_key_pair" "terraform" {
	
  key_name   = "devops-terraform"
  public_key = file("devops.pub")
  tags = {
    Name = "terraform"

  }
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project}-vpc-${var.env}"
    Project = var.project
    Enviornment = var.env
  }
}

```

### Subnet Creation

```
resource "aws_subnet" "public1" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 0)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.myAZ.names[0]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_subnet" "public2" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 1)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.myAZ.names[1]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_subnet" "public3" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 2)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.myAZ.names[2]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_subnet" "private1" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 3)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.myAZ.names[0]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_subnet" "private2" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 4)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.myAZ.names[1]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_subnet" "private3" {
	
	vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, "3", 5)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.myAZ.names[2]
    tags = {
      Name = "${var.project}-public1-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}
```
### Internet Gateway Creation

```
resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${var.project}-igw-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
}
```

### Elastic IP creation

```
resource "aws_eip" "nat" {
  vpc  = true
  tags = {
      Name = "${var.project}-nat-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}
```
### NAT Gateway Creation

```
resource "aws_nat_gateway" "nat" {
	
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public2.id
  tags = {
      Name = "${var.project}-nat-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
  depends_on = [aws_internet_gateway.igw]

}
```

### Route Table Creation for private and public

```
resource "aws_route_table" "rtpublic" {
	
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      Name = "${var.project}-rtpublic-${var.env}"
      Project = var.project
      Enviornment = var.env

  }
}


resource "aws_route_table" "rtprivate" {
	
	vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
      Name = "${var.project}-rtprivate-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

```
### Route table Association

```
resource "aws_route_table_association" "public1" {
	
	subnet_id      = aws_subnet.public1.id
    route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "public2" {
	
	subnet_id      = aws_subnet.public2.id
    route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "public3" {
	
	subnet_id      = aws_subnet.public3.id
    route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "private1" {
	
	subnet_id      = aws_subnet.private1.id
    route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "private2" {
	
	subnet_id      = aws_subnet.private2.id
    route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "private3" {
	
	subnet_id      = aws_subnet.private3.id
    route_table_id = aws_route_table.rtprivate.id
}
```

### Security Group Creation

```
#======================================================
#Creating Security Groups
#======================================================


resource "aws_security_group" "bastion" {
	
  name        = "bastion"
  description = "Allow ssh access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = "${var.project}-bastion-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_security_group" "webserver" {
	
  name        = "webserver"
  description = "Allow ssh access from bastion and http from anywhere"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ aws_security_group.bastion.id ]
  }

  ingress {
    description      = "webserver access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "webserver access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
      Name = "${var.project}-webserver-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

resource "aws_security_group" "database" {
	
  name        = "database"
  description = "Allow ssh access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
  }

  ingress {
    description      = "db access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.webserver.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = "${var.project}-database-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

```

### EC2 Creation

```

#=====================================
#  EC2-Creation
#=====================================

resource "aws_instance" "webserver" {
  
  ami           = data.aws_ami.amiimage.id
  instance_type = var.type
  key_name = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.webserver.id ]
  availability_zone = data.aws_availability_zones.myAZ.names[1]
  subnet_id = aws_subnet.public2.id
  user_data = file("setup_webserver.sh")
  tags = {
      Name = "${var.project}-webserver-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
}

resource "aws_instance" "bastion" {

  ami                    = data.aws_ami.amiimage.id
  instance_type          = var.type
  key_name               = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.bastion.id ]
  availability_zone      = data.aws_availability_zones.myAZ.names[1]
  subnet_id              = aws_subnet.public2.id
  user_data              = file("setup_bastion.sh")
  tags = {
      Name = "${var.project}-bastion-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
}


resource "aws_instance" "database" {

  ami                    = data.aws_ami.amiimage.id
  instance_type          = var.type
  key_name               = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.database.id ]
  availability_zone      = data.aws_availability_zones.myAZ.names[1]
  subnet_id              = aws_subnet.private2.id
  user_data              = file("setup_database.sh")
  tags = {
      Name = "${var.project}-database-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
}

```

You can use the below userdata to pre-load the hostname and neccessary files in the servers,

```sh
vi setup_bastion.sh
```

```
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
sudo hostnamectl set-hostname bastion-server
```

```sh
vi setup_webserver.sh
```

```
#!/bin/bash


echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

sudo hostnamectl set-hostname webserver

service sshd restart

sudo yum install httpd php -y; service httpd restart; systemctl enable httpd.service

cat <<EOF > /var/www/html/index.php
<?php
\$output = shell_exec('echo $HOSTNAME');
echo "<h1><center><pre>\$output</pre></center></h1>";
echo "<h1><center> Terraform website </center></h1>"
?>
EOF

service httpd restart
chkconfig httpd on
```

```sh
vi setup_database.sh
```

```
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
sudo hostnamectl set-hostname db-server

sudo service sshd restart
```



## Terraform commands

#### Terraform Validation

Validate the terraform files using the below command, by this we can make sure that there is no syntax error.

```sh
terraform validate
```
#### Terraform Plan

Terraform plan command creates an execution plan, also let us know the preview changes that Terraform plans to make to your infrastructure

```sh
terraform plan
```
#### Terraform Apply

Lets apply the above architecture to the AWS.

```sh
terraform apply
```

#### You can change the values of variables as per your requirement in variables.tf file.


