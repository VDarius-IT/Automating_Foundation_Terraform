output "vpc_id" {
  description = "VPC ID created by the vpc module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet ids"
  value       = module.vpc.public_subnet_ids
}
