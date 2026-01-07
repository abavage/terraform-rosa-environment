# Make it work
# brew install session-manager-plugin
# aws ssm start-session --target <instance_id> --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3389"],"localPortNumber":["13389"]}'

# then in the rpd client
# server: localhost:13389
# user: admin
# password: The.Strong-Password123!


resource "aws_security_group" "windows" {
  name   = "windows-ec2-common"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "windows-ec2-common"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.windows.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "random_pet" "windows_instance_name" {}

resource "aws_instance" "ec2_windows" {
  count = var.deploy_windows_instance ? 1 : 0

  ami                         = data.aws_ami.windows.id
  subnet_id                   = tolist(data.aws_subnets.private_subnets.ids)[1]
  vpc_security_group_ids      = [aws_security_group.windows.id]
  instance_type               = "t3.medium"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_role.name
  associate_public_ip_address = false
  root_block_device {
    volume_size = "30"
  }
  metadata_options {
    http_tokens   = "optional"
    http_endpoint = "enabled"
  }
  #count = 1

  #user_data                   = file("${path.module}/userdata/windows.ps1")
  #user_data                    = data.template_file.user_data.rendered


  user_data = templatefile("${path.module}/userdata/windows.ps1",
    {
      rdp_user     = var.rdp_user
      rdp_password = var.rdp_password
    }
  )
  user_data_replace_on_change = true

  #user_data = <<EOF
  #<powershell>
  ## Enable RDP (local policy allows RDP sessions)
  #Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

  ## Allow RDP in Windows Firewall
  #Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

  ## Create temporary user
  #$password = ConvertTo-SecureString "${var.rdp_password}" -AsPlainText -Force
  #New-LocalUser -Name "${var.rdp_user}" -Password $password
  #Add-LocalGroupMember -Group "Administrators" -Member "${var.rdp_user}"
  #</powershell>
  #EOF

  tags = merge(
    var.tags,
    {
      #Name = "${var.ec2_windows_bastion_name}-${count.index}"
      Name = "${var.ec2_windows_bastion_name}-${random_pet.windows_instance_name.id}"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [
    aws_route_table_association.public,
    aws_route_table_association.private
  ]
}