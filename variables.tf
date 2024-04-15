# Define variables
variable "instance_sg_name" {
  type        = string
  description = "The name of the sg "
}

variable "ami" {
  type        = string
  description = "ami id "
}

variable "instance_type" {
  type        = string
  description = "instance type"
}

variable "key_pair" {
  type        = string
  description = "keypair for server "
}

variable "subnet_id" {
  type        = string
  description = "subnet id from above stage"
}

variable "vpc_id" {
  type        = string
  description = "vpc id from above stage "
}
