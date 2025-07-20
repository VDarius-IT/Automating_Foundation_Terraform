# Automated AWS Infrastructure with Terraform

This project demonstrates a robust, repeatable, and version-controlled system for deploying and managing AWS infrastructure using Terraform. It showcases an Infrastructure as Code (IaC) approach to provision core networking (VPCs, Subnets), security (IAM), databases (RDS), and scalable compute resources (EC2).

The core philosophy is to treat infrastructure as software: versioned in Git, deployed through automated CI/CD pipelines, and structured for maximum reusability and maintainability.

---

## 📋 Table of Contents

*   [Key Features](#-key-features)
*   [Architecture Overview](#-architecture-overview)
*   [Getting Started](#-getting-started)
    *   [Prerequisites](#prerequisites)
    *   [Installation & Setup](#installation--setup)
*   [Usage](#-usage)
    *   [Deploying the Infrastructure](#deploying-the-infrastructure)
    *   [Example: Creating a VM Cluster](#example-creating-a-vm-cluster)
*   [Project Structure](#-project-structure)
*   [Automation: CI/CD and Drift Detection](#-automation-cicd-and-drift-detection)
*   [Contributing](#-contributing)

---

##  Key Features

*   **Declarative Infrastructure as Code:** Defines the entire AWS infrastructure in human-readable HCL, eliminating manual configuration errors.
*   **Modular and Reusable:** Uses Terraform Modules for components like VPCs and RDS, making the architecture clean and easy to scale.
*   **Multi-Environment Management:** Leverages Terraform Workspaces to manage `dev`, `staging`, and `prod` environments with the same codebase, ensuring consistency.
*   **Scalable VM Cluster Deployment:** Easily create any number of configured virtual machines from a "golden image" using simple variable changes.
*   **Automated CI/CD Pipeline:** Integrates with CI/CD tools (e.g., GitHub Actions) to validate, plan, and apply infrastructure changes automatically.
*   **Proactive Drift Detection:** Includes an automated mechanism to detect any manual changes made to the infrastructure, ensuring the live environment never deviates from its code definition.

---

##  Architecture Overview

This project uses Terraform to manage the lifecycle of AWS resources.

1.  **Modules:** The infrastructure is broken down into reusable **modules** (e.g., `vpc`, `iam`, `ec2`). This keeps the root configuration clean and allows modules to be reused across different projects.
2.  **Workspaces:** To manage separate environments (`dev`, `prod`), Terraform **workspaces** are used. Each workspace has its own state file, ensuring that changes in a development environment do not affect production.
3.  **State Management:** Terraform's state is stored remotely and securely in an AWS S3 bucket with state locking enabled via DynamoDB to prevent conflicts during team collaboration.

---

##  Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following tools installed and configured:

*   **Terraform v1.0+:** [Download Terraform](https://developer.hashicorp.com/terraform/install)
*   **AWS CLI:** [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*   **Configured AWS Credentials:** Your AWS account credentials must be configured for Terraform to access your account. You can do this by running `aws configure`.

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name
    ```

2.  **Initialize Terraform:**
    This command initializes the backend, downloads provider plugins, and sets up the modules.
    ```sh
    terraform init
    ```

---

##  Usage

### Deploying the Infrastructure

1.  **Select a Workspace:**
    It's best practice to create a workspace for your environment.
    ```sh
    # Create and switch to a new 'dev' workspace
    terraform workspace new dev
    ```

2.  **Review the Execution Plan:**
    Run `terraform plan` to see what changes will be made to your infrastructure. This is a safe way to check your work before applying.
    ```sh
    # Create a plan using variables from the dev environment
    terraform plan -var-file="environments/dev.tfvars"
    ```

3.  **Apply the Changes:**
    If the plan is acceptable, apply it to build the infrastructure.
    ```sh
    # Apply the plan
    terraform apply -var-file="environments/dev.tfvars"
    ```

### Example: Creating a VM Cluster

To create a cluster of 15 Windows Server 2019 virtual machines, simply modify your variables file (`.tfvars`) and apply.

1.  **Define your cluster in `dev.tfvars`:**
    ```terraform
    # environments/dev.tfvars

    # Set the desired number of VMs
    vm_count = 15
    
    # Specify the pre-built "golden image" AMI ID
    golden_ami_id = "ami-0a1b2c3d4e5f67890" 
    
    # Specify the instance type (CPU/RAM)
    instance_type = "t3.large"
    
    # Define a name prefix for the VMs
    vm_name_prefix = "DC"
    ```

2.  **Apply the configuration:**
    Terraform will automatically create 15 EC2 instances, named `DC-1`, `DC-2`, etc., each with the specified OS and hardware configuration.
    ```sh
    terraform apply -var-file="environments/dev.tfvars"
    ```

---

## 📂 Project Structure

The repository is organized to promote modularity and clarity.

```text
.
├── main.tf # Root module - main entry point
├── variables.tf # Root variable definitions
├── outputs.tf # Root outputs
├── terraform.tf # Terraform backend and provider configuration
├── environments/ # Environment-specific variable files
│ ├── dev.tfvars
│ └── prod.tfvars
└── modules/ # Reusable infrastructure modules
├── vpc/ # VPC, Subnets, IGW, NAT Gateway
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── ec2-instance/ # EC2 Instance cluster module
│ ├── main.tf
│ └── ...
└── rds/ # RDS Database module
├── main.tf
└── ...
```

---

##  Automation: CI/CD and Drift Detection

This project is designed to be managed through a CI/CD pipeline.

**CI Pipeline (on Pull Request):**
1.  **`terraform fmt -check`**: Verifies that all code is correctly formatted.
2.  **`terraform validate`**: Checks for syntax errors in the configuration.
3.  **`terraform plan`**: Creates an execution plan and posts it as a comment to the pull request for peer review. No changes are applied.

**CD Pipeline (on Merge to `main`):**
1.  **`terraform apply -auto-approve`**: Automatically applies the changes to the production environment.

**Infrastructure Drift Detection:**
*   A scheduled job runs `terraform plan` daily against the production environment.
*   If the plan is not empty (meaning a manual change was detected), it triggers an alert to the operations team.
*   This ensures the infrastructure state never deviates from the master branch, maintaining its integrity.

---

##  Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/your-username/your-repo-name/issues).
