<powershell>
  # Enable RDP (local policy allows RDP sessions)
  Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

  # Allow RDP in Windows Firewall
  Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

  # Create temporary user
  $password = ConvertTo-SecureString "${rdp_password}" -AsPlainText -Force
  New-LocalUser -Name "${rdp_user}" -Password $password
  Add-LocalGroupMember -Group "Administrators" -Member "${rdp_user}"
</powershell>