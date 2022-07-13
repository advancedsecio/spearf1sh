resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_spearf1sh"

  ingress {
    from_port        = "22"
    to_port          = "22"
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "spearf1sh"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "vm" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "c6a.24xlarge"
  availability_zone = "eu-central-1b"
  key_name          = aws_key_pair.ssh.key_name
  security_groups   = [aws_security_group.allow_ssh.name]

  root_block_device {
    volume_size = 1000
  }

  connection {
    host        = self.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.ssh.private_key_openssh
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Working"
    ]
  }
}