# Automated AWS Infrastructure with Terraform

This repository provides a production-ready framework for provisioning and managing AWS infrastructure using Terraform. It follows Infrastructure as Code (IaC) principles to create a version-controlled, repeatable, and automated system for core cloud resources.

The architecture is designed to be modular, scalable, and secure, suitable for managing multiple environments (e.g., development, staging, production) from a single codebase.

### Table of Contents

1.  [Core Features](#core-features)
2.  [Architecture Overview](#architecture-overview)
3.  [Prerequisites](#prerequisites)
4.  [Setup and Configuration](#setup-and-configuration)
5.  [Core Workflow](#core-workflow)
6.  [Project Structure](#project-structure)
7.  [Automation: CI/CD and Drift Detection](#automation-cicd-and-drift-detection)
8.  [Security Considerations](#security-considerations)
9.  [Cost Management](#cost-management)
10. [Contributing](#contributing)
11. [License](#license)

---

### Core Features

*   **Declarative Infrastructure:** The entire AWS infrastructure (VPC, EC2, RDS, IAM) is defined in HCL, eliminating manual configuration and ensuring consistency.
*   **Modular Architecture:** Components like networking and compute are encapsulated in reusable modules, promoting clean design and separation of concerns.
*   **Environment Isolation:** Terraform Workspaces are used to manage distinct environments (dev, prod) with isolated state files, preventing cross-environment interference.
*   **Secure Remote State:** Utilizes an S3 backend for state storage and a DynamoDB table for state locking, enabling safe collaboration within a team.
*   **CI/CD Automation:** Integrates with GitHub Actions to validate, plan, and apply infrastructure changes, enforcing a code-review-first workflow.
*   **Automated Drift Detection:** A scheduled mechanism automatically detects manual changes made to the infrastructure, ensuring the live environment never deviates from its code definition.

### Architecture Overview

The project is built on three foundational concepts:

*   **Modules:** Each distinct piece of infrastructure (e.g., `vpc`, `ec2-cluster`) is a self-contained module with its own inputs, outputs, and README. The root `main.tf` file assembles these modules to build the complete architecture.
*   **Remote State:** The Terraform state file, which maps resources to your configuration, is stored remotely in an AWS S3 bucket. A DynamoDB table acts as a locking mechanism to prevent multiple users from running `apply` at the same time and corrupting the state.
*   **Workspaces:** A workspace corresponds to an environment. This allows you to deploy the same configuration to `dev` and `prod` while maintaining separate state files and using different variable values for each.

### Prerequisites

Ensure the following tools are installed and configured on your local machine:

*   **Terraform v1.4+**: [Download Terraform](https://www.terraform.io/downloads.html)
*   **AWS CLI**: [Install AWS CLI](https://aws.amazon.com/cli/)
*   **Configured AWS Credentials**: Configure your credentials, preferably using a dedicated IAM role or user for Terraform.
    ```sh
    aws configure
    ```

### Setup and Configuration

**1. Clone the Repository**
```sh
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

**2. Configure the Terraform Backend**

This project requires an S3 bucket and a DynamoDB table to manage its state.

*   **Create the S3 Bucket** (Replace `<your-unique-bucket-name>` and `<your-aws-region>`):
    ```sh
    aws s3 mb s3://<your-unique-bucket-name> --region <your-aws-region>
    ```

*   **Create the DynamoDB Table** (Replace `<your-aws-region>`):
    ```sh
    aws dynamodb create-table \
        --table-name terraform-state-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region <your-aws-region>
    ```

*   **Update Backend Configuration:**
    Modify the `backend.tf` file with your bucket name, desired state file key, and region.

    ```hcl
    # backend.tf
    terraform {
      backend "s3" {
        bucket         = "<your-unique-bucket-name>" # UPDATE THIS
        key            = "your-project/terraform.tfstate"
        region         = "<your-aws-region>"         # UPDATE THIS
        dynamodb_table = "terraform-state-lock"
        encrypt        = true
      }
    }
    ```

**3. Initialize Terraform**

This command downloads the necessary provider plugins and initializes the configured backend.
```sh
terraform init
```

### Core Workflow

Follow these steps to deploy or modify the infrastructure.

**1. Select a Workspace**

Create a workspace for your target environment if it doesn't exist.
```sh
# Create and switch to a new 'dev' workspace
terraform workspace new dev

# Or, select an existing one
terraform workspace select dev
```

**2. Review the Execution Plan**

Generate a plan to preview the changes Terraform will make. This is a safe, read-only operation.
```sh
# Create a plan using variables from the dev environment
terraform plan -var-file="environments/dev.tfvars"
```

**3. Apply the Changes**

If the plan is acceptable, apply it to build or update the infrastructure.
```sh
# Apply the plan (you will be prompted for confirmation)
terraform apply -var-file="environments/dev.tfvars"
```

**4. Destroying the Infrastructure**

To tear down all resources managed by this configuration and avoid ongoing costs, run the destroy command.
```sh
# Ensure you are in the correct workspace first
terraform workspace select dev

# Use the same variables file to ensure all resources are targeted
terraform destroy -var-file="environments/dev.tfvars"
```

### Project Structure

The repository is organized to promote modularity, clarity, and separation of configuration from logic.

```
.
├── .github/workflows/      # CI/CD pipeline definitions (e.g., deploy.yml)
├── environments/           # Environment-specific variable files
│   ├── dev.tfvars
│   └── prod.tfvars
├── modules/                # Reusable infrastructure modules
│   ├── vpc/                # Creates VPC, Subnets, IGW, NAT Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── ec2-cluster/        # Creates a scalable cluster of EC2 instances
│   └── rds/                # Creates an RDS Database instance
├── main.tf                 # Root module: main entry point that calls other modules
├── variables.tf            # Root variable definitions
├── outputs.tf              # Root outputs (e.g., RDS endpoint, LB DNS)
├── backend.tf              # Terraform backend configuration
└── .gitignore              # Files and directories to ignore
```

### Automation: CI/CD and Drift Detection

**CI Pipeline (on Pull Request)**
The pipeline in `.github/workflows/` triggers on pull requests against `main` and performs the following checks:
1.  `terraform fmt -check`: Verifies HCL code is correctly formatted.
2.  `terraform init`: Initializes the backend and providers.
3.  `terraform validate`: Checks for syntax errors.
4.  `terraform plan`: Creates an execution plan and posts it to the PR for peer review. No changes are applied.

**CD Pipeline (on Merge to `main`)**
Upon merging a pull request to the `main` branch, the pipeline automatically applies the changes to the production environment:
1.  `terraform workspace select prod`
2.  `terraform apply -auto-approve`

**Infrastructure Drift Detection**
A scheduled GitHub Action runs daily against the production environment:
1.  It executes a `terraform plan`.
2.  If the plan is not empty (indicating a manual change was made in the AWS Console), it triggers an alert to notify the operations team. This ensures the infrastructure state never deviates from the main branch.

### Security Considerations

*   **Least Privilege:** IAM roles and policies are configured to grant only the minimum permissions necessary for services to function. The IAM user/role running Terraform should also be restricted.
*   **Secrets Management:** Sensitive data like database passwords or API keys should **not** be stored in `.tfvars` files. Integrate with a service like AWS Secrets Manager or HashiCorp Vault.
*   **Network Security:** Security Groups are used to control traffic between resources, defaulting to a deny-all inbound posture.
*   **State File Security:** The S3 backend is configured to encrypt the state file at rest. Access should be tightly restricted via IAM policies.

### Cost Management

Be aware that deploying this infrastructure will incur costs on your AWS account.
*   **Primary Cost Drivers:** EC2 instances, RDS databases, NAT Gateways, and data transfer are the main sources of cost.
*   **Estimate Costs:** Use the [AWS Pricing Calculator](https://calculator.aws/) to estimate monthly costs before a production deployment.
*   **Clean Up:** To avoid ongoing charges, always run `terraform destroy` when you are finished experimenting.

### Contributing

Contributions, issues, and feature requests are welcome. Please open an issue to discuss your ideas or submit a pull request with your proposed changes.

### License

This project is distributed under the MIT License. See `LICENSE` for more information.
