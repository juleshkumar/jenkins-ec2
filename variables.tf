# Define variables
variable "instance_sg_name" {
  description = "The name of the sg "
}

variable "vpc_id" {
  description = "The vpc id "
}

variable "ami" {
  description = "ami id "
}

variable "instance_type" {
  description = "instance type"
}

variable "subnet_id" {
  description = "subnet id for az "
}

variable "key_pair" {
  description = "keypair for server "
}

