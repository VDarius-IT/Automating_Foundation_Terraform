#!/usr/bin/env bash
set -euo pipefail

# Simple helper to create an S3 bucket and DynamoDB table for Terraform state.
# Usage: ./scripts/create-backend.sh <bucket-name> <aws-region>
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <s3-bucket-name> <aws-region>"
  exit 1
fi

bucket="$1"
region="$2"
table="terraform-state-lock"

echo "Creating S3 bucket (if not exists): $bucket in region $region"
aws s3api create-bucket --bucket "$bucket" --region "$region" --create-bucket-configuration LocationConstraint="$region" 2>/dev/null || echo "Bucket may already exist or you don't have permissions."

echo "Enabling encryption on bucket (server-side encryption)"
aws s3api put-bucket-encryption --bucket "$bucket" --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}' || echo "Could not set encryption (check permissions)."

echo "Creating DynamoDB table for state lock: $table"
aws dynamodb create-table \
  --table-name "$table" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region "$region" 2>/dev/null || echo "Table may already exist or you don't have permissions."

echo "Backend bootstrap complete. Update backend.tf with the bucket name and region."
