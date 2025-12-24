# Network Setup

## Required Setup for ROSA clusters

### Connecting to the Windows instance in a Private Subnet
The windows ec2 instance is deployed by default in a private subnet. It has an ec2 instace role attached so SSM can be leveraged without the RDP protocal being used via port `3389`. A security group is required to be attached to the instance with only on outbound 0.0.0.0/0. No inbound is required.

```
$ brew install session-manager-plugin

$ aws ssm start-session --target <instance_id> --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3389"],"localPortNumber":["13389"]}'

# From an RDP Client

server: localhost:13389
user: admin
password: The.Strong-Password123!
```

### Overriding username and password
Both can be overridden in `*.tfvars`

```
var.rdp_user
var.rdp_password
```

### Second Connection Option
Can use Systems Manager `->` Fleet Manager `->` Node Actions `->` Connect `->` Connect with Remote Desktop.
Supply the username and password from:
```
var.rdp_user
var.rdp_password
```


The windows instance is `not` deployed by default. It is toggled on in `*.tfvars` using `deploy_windows_instance = true`    



### Example TF with a for_each against a bool variable
```
resource "aws_route_table_association" "public" {
  for_each = var.public ? aws_subnet.aws_subnet_public : {}

  subnet_id      = each.value.id
  route_table_id = try(aws_route_table.default[0].id, null)

  depends_on = [
    aws_route_table.default
  ]
}
```

### Detailed explination
```
If var.public is true, Terraform iterates over the aws_subnet.aws_subnet_public map and creates one instance of the resource for each public subnet. If var.public is false, Terraform uses an empty map ({}), resulting in zero instances of the resource being created. This is a best-practice pattern for conditionally creating resources with for_each, because it avoids count indexing issues and ensures Terraform does not evaluate references when the feature is disabled.


try(aws_route_table.default[0].id, null) safely handles optional resources in Terraform by returning the route table ID when it exists and null when it does not. 

Prevents Terraform from failing with an “invalid index” error when the route table is disabled using count = 0 (with the bool variable in mind). The try() function evaluates expressions in order and suppresses errors, while null tells Terraform to ignore the argument entirely. This pattern is very useful for feature toggles, optional resources, making configurations more robust and future-proof.
```