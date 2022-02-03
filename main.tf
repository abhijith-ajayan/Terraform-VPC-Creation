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

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${var.project}-igw-${var.env}"
      Project = var.project
      Enviornment = var.env
  }
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = {
      Name = "${var.project}-nat-${var.env}"
      Project = var.project
      Enviornment = var.env
  }

}

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
