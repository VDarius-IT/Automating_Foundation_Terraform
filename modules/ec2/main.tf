variable "instance_type" {
  type = string
}

variable "ami_name" {
  type = string
  description = "AMI name filter (e.g., amazon-linux-2)"
  default = "amazon-linux-2"
}

variable "subnet_id" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {}
}

data "aws_ami" "linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "demo" {
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  tags = merge(var.tags, { Name = "${var.tags["Project"]}-ec2-demo" })
  # Keep minimal for demo. Add security groups and SSH key in production.
}
output "instance_id" {
  value = aws_instance.demo.id
}
