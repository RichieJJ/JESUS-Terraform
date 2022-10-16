resource "aws_vpc" "richie_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "richie_vpc"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.richie_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true


  tags = {
    Name = "richie_pub_subnet"
  }
}

resource "aws_subnet" "priv_subnet" {
  vpc_id                  = aws_vpc.richie_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false


  tags = {
    Name = "richie_priv_subnet"
  }
}

resource "aws_internet_gateway" "richie_IGW" {
  vpc_id = aws_vpc.richie_vpc.id

  tags = {
    Name = "richie_IGW"
  }
}

resource "aws_route_table" "richie_pub_RT" {
  vpc_id = aws_vpc.richie_vpc.id

  tags = {
    Name = "richie_pub_RT"
  }
}

resource "aws_route_table" "richie_priv_RT" {
  vpc_id = aws_vpc.richie_vpc.id

  tags = {
    Name = "richie_priv_RT"
  }
}

resource "aws_route" "richie_route" {
  route_table_id         = aws_route_table.richie_pub_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.richie_IGW.id
}

resource "aws_route_table_association" "pub_RT_Asso" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.richie_pub_RT.id

}

resource "aws_security_group" "richie_sg" {
  name        = "richie_sg"
  description = "richie pub subnet sg"
  vpc_id      = aws_vpc.richie_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["68.225.132.20/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "mtc-keypair" {
  key_name   = "mtc-keypair"
  public_key = file("~/.ssh/mtc-keypair.pub")
}

resource "aws_instance" "dev-node" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.server_ami.id
  key_name  = aws_key_pair.mtc-keypair.id
  vpc_security_group_ids = [aws_security_group.richie_sg.id]
  subnet_id = aws_subnet.pub_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
  volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
        hostname = self.public_ip,
        user = "ubuntu",
        identityfile = "~/.ssh/mtc-keypair"
  })
    interpreter = ["zsh", "-c"]
  }
}



