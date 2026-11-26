variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "my_ip" {
  description = "Your public IP in CIDR form, allowed to SSH in (e.g. 203.0.113.10/32)"
  type        = string
  default     = "203.0.113.10/32"
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI for your region"
  type        = string
  default     = "ami-0f58b397bc5c1f2e8"
}

variable "instance_type" {
  description = "EC2 size (t3.micro is in the free tier)"
  type        = string
  default     = "t3.micro"
}
