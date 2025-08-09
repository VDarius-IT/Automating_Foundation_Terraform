variable "allocated_storage" { type = number }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "username" { type = string }
variable "password" { type = string }
variable "subnet_ids" { type = list(string) }
variable "tags" { type = map(string) }

resource "aws_db_subnet_group" "this" {
  name       = "${var.tags["Project"]}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot  = true
  tags = var.tags
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}
