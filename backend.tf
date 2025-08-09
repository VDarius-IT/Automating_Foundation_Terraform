# Default backend configuration: Uncomment and fill values to use S3 backend.
# terraform {
#   backend "s3" {
#     bucket         = "<your-unique-bucket-name>" # UPDATE THIS
#     key            = "automating-foundation/terraform.tfstate"
#     region         = "<your-aws-region>"         # UPDATE THIS
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# For quick local testing, we fall back to the default local backend (no configuration needed).
