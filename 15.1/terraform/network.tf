
/* Public */
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.netology-vpc.id
  cidr_block = "172.31.32.0/19"
  availability_zone = var.aws-av-zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
  }
}
resource "aws_internet_gateway" "netology-gw" {
  vpc_id = aws_vpc.netology-vpc.id
  tags = {
    Name = "netology-gw"
  }
}
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.netology-vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.netology-gw.id
    }
  tags = {
    Name = "public-route"
  }
}
resource "aws_route_table_association" "netology-rta1" {
     subnet_id      = aws_subnet.public.id
     route_table_id = aws_route_table.public-route.id
}

resource "aws_instance" "server1" {
  ami           = data.aws_ami.centos.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  key_name  = aws_key_pair.laptop.key_name
  count = local.web_instance_count_map[terraform.workspace]
  subnet_id = aws_subnet.public.id
  availability_zone = var.aws-av-zone
  associate_public_ip_address = "true"
  security_groups = [ aws_security_group.netology-sg.id ]
  private_ip = "172.31.32.5"
  instance_initiated_shutdown_behavior = "stop"
  tags = {
    Name = "Server1"
  }
}
/* Private */
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.netology-vpc.id
  cidr_block = "172.31.64.0/19"
  availability_zone = var.aws-av-zone

  tags = {
    Name = "private"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "netology-nat-gw" {
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.nat_gateway.id

  tags = {
    Name = "netology-nat-gw"
  }
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.netology-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.netology-nat-gw.id
    }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "netology-rta2" {
     subnet_id      = aws_subnet.private.id
     route_table_id = aws_route_table.private-route.id
}

resource "aws_instance" "server2" {
  ami           = data.aws_ami.centos.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  key_name  = aws_key_pair.laptop.key_name
  count = local.web_instance_count_map[terraform.workspace]
  subnet_id = aws_subnet.private.id
  availability_zone = var.aws-av-zone
  associate_public_ip_address = "true"
  security_groups = [ aws_security_group.netology-sg.id ]
  private_ip = "172.31.88.5"
  instance_initiated_shutdown_behavior = "stop"
  tags = {
    Name = "Server2"
  }
}