resource "aws_key_pair" "ssh_key" {
  key_name   = "one"
  public_key = file("~/.ssh/one_id_rsa.pub")
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.2024*-x86_64"]
  }
}


resource "aws_instance" "vm" {
  ami           = data.aws_ami.amazon-linux.id
  subnet_id      = tolist(data.aws_subnets.rosa_public_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]
  instance_type = "t3.micro"
  key_name        = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "optional"
    http_endpoint = "enabled"
  }
  count = 1
  tags = {
    Name = "one"
    another_tag = "tf-node"
  }
  user_data = file("doit.sh")
}
