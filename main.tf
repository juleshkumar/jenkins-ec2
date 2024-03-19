resource "aws_security_group" "jumpbox_sg" {
  name        =  var.instance_sg_name
  description = "Security group for the EC2 instance"
  vpc_id      = var.vpc_id

  // Define ingress rules as needed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Define egress rules as needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jumpbox" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  key_name        = var.key_pair
  security_groups = [aws_security_group.jumpbox_sg.id]
  associate_public_ip_address = true

  // Define additional configuration as needed
  // For example, user_data, tags, etc.
  
  // Define root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30  # Size in GB
    delete_on_termination = true
  }
}
