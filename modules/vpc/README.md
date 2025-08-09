Simple VPC module
Creates:
- VPC
- Internet Gateway
- Public subnets (one per provided CIDR)

Inputs:
- vpc_cidr
- public_subnets (list)

Outputs:
- vpc_id
- public_subnet_ids
