resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "sn1" {
  cidr_block = "10.0.0.0/26"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "mysubnet1a"
  }
}

resource "aws_subnet" "sn2" {
  cidr_block = "10.0.0.64/26"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "mysubnet1b"
  }
}

resource "aws_security_group" "sg1" {
  name = "sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port = 444
    to_port = 444
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 81
    to_port = 81
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route1" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.sn1.id
}

resource "aws_route_table_association" "route2" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.sn2.id
}