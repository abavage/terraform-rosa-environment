variable "aws_region" {
  type        = string
  description = "aws region"
  nullable    = false
}

variable "vpc_cidr" {
  type        = string
  description = "defualt vpc cidr"
  default     = null
}

variable "aws_subnet_public" {
  type        = map(string)
  description = "aws subnet public cidr and subnet"
  nullable    = false
}

variable "aws_subnet_private" {
  type        = map(string)
  description = "aws subnet private cidr and subnet"
  nullable    = false
}

variable "tags" {
  description = "Apply user defined tags to all cluster resources created in AWS"
  type        = map(string)
  default     = null
}

variable "public" {
  type        = bool
  description = "Is this public or private environment"
  default     = true
}

variable "common_ec2_sg_rules" {
  type        = map(any)
  description = "default security group rules"
  default     = null
}

variable "ec2_bastion_public_source_subnet" {
  type        = bool
  description = "Is the linux ec2 instance in a public or private subnet"
  default     = false
}

variable "ec2_linux_bastion_name" {
  type        = string
  description = "name tpo add to the linux bastion host"
  default     = null
}

variable "ec2_windows_bastion_name" {
  type        = string
  description = "name tpo add to the windows bastion host"
  default     = null
}

variable "deploy_windows_instance" {
  type        = bool
  description = "deploy windows ec2 instace"
  default     = false
}

variable "rdp_user" {
  description = "Temporary RDP username"
  type        = string
  default     = "admin"
}

variable "rdp_password" {
  description = "Temporary RDP password"
  type        = string
  default     = "The.Strong-Password123!"
}

variable "linux_instance_count" {
  type    = number
  default = null
}

variable "create_vpce_private_rosa_cluster" {
  type        = bool
  description = "create all the required vpce's for a private rosa cluster"
  default     = false
}