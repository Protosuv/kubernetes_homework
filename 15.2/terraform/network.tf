
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

/* Private */
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.netology-vpc.id
  cidr_block = "172.31.96.0/19"
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