
# create security group
resource "aws_security_group" "ec2-sg" {
  name   = "ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "ec2-sg"
  }
}

data "aws_ami" "linux-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# create key pair for ssh ec2
resource "aws_key_pair" "ssh-key" {
  key_name   = var.key_name
  public_key = file(var.public_key_location)
}


resource "aws_instance" "server" {
  count = 2
  ami           = data.aws_ami.linux-ami.id
  key_name      = aws_key_pair.ssh-key.key_name
  instance_type = var.instance_type
  vpc_security_group_ids  = [aws_security_group.ec2-sg.id]

  tags = {
    Name = "NginxServerInstance"
  }

  user_data = file("script.sh")

}

resource "aws_eip" "static_eip" {
    instance = aws_instance.server.1.id
}

