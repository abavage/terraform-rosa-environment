variable "my_subs" {
  description = "my subnets"
  type = list(any)
  default = ["subnet-02e202b5aab2cb05b", "subnet-04fe077922ef6d57b", "subnet-09ec769bb1d92803b"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "rosa-hcp-0"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Cidr block of the desired VPC."
}

variable "common_tags" {
  type        = map(string)
  description = "common tags"
  default = {
    "customer" : "development",
    "primary_application" : "httpd"
  }
}

variable "rosa_public_subnet" {
  type        = map(string)
  description = "Public Subnet and CIDR values"
  default = {
    "ap-southeast-2a" : "10.0.2.0/23",
    "ap-southeast-2b" : "10.0.4.0/23",
    "ap-southeast-2c" : "10.0.6.0/23"
  }
}

variable "rosa_private_subnet" {
  type        = map(string)
  description = "Private Subnet and CIDR values"
  default = {
    "ap-southeast-2a" : "10.0.8.0/23",
    "ap-southeast-2b" : "10.0.10.0/23",
    "ap-southeast-2c" : "10.0.12.0/23"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "security_group_port" {
  type = map(string)
  default = {
    "ssh": "22",
    "http": "80",
    "https": "443"
  }
}

variable "security_group_default_allow_ip" {
  type = map(string)
  default = {
   "ingress" = "0.0.0.0/0",
   "egress"  = "0.0.0.0/0"
  }
}

variable "ec2_sg_rules" {
  type = map(any)
  default = {
    "ssh" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
    }
    "http" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
    }
    "https" = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
    }
    "squid" = {
      from_port   = 3128
      to_port     = 3128
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
    }
  }
}

variable "terraform_state_bucket" {
  type        = string
  default     = "rosa-environment-state"
  description = "defautl state bucket for the aws environment"
}
