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
*   [License](#-license)

---

## ✨ Key Features

*   **Declarative Infrastructure as Code:** Defines the entire AWS infrastructure in human-readable HCL, eliminating manual configuration errors.
*   **Modular and Reusable:** Uses Terraform Modules for components like VPCs and RDS, making the architecture clean and easy to scale.
*   **Multi-Environment Management:** Leverages Terraform Workspaces to manage `dev`, `staging`, and `prod` environments with the same codebase, ensuring consistency.
*   **Scalable VM Cluster Deployment:** Easily create any number of configured virtual machines from a "golden image" using simple variable changes.
*   **Automated CI/CD Pipeline:** Integrates with CI/CD tools (e.g., GitHub Actions) to validate, plan, and apply infrastructure changes automatically.
*   **Proactive Drift Detection:** Includes an automated mechanism to detect any manual changes made to the infrastructure, ensuring the live environment never deviates from its code definition.

---

## 🏛️ Architecture Overview

This project uses Terraform to manage the lifecycle of AWS resources.

1.  **Modules:** The infrastructure is broken down into reusable **modules** (e.g., `vpc`, `iam`, `ec2`). This keeps the root configuration clean and allows modules to be reused across different projects.
2.  **Workspaces:** To manage separate environments (`dev`, `prod`), Terraform **workspaces** are used. Each workspace has its own state file, ensuring that changes in a development environment do not affect production.
3.  **State Management:** Terraform's state is stored remotely and securely in an AWS S3 bucket with state locking enabled via DynamoDB to prevent conflicts during team collaboration.

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following tools installed and configured:

*   **Terraform v1.0+:** [Download Terraform](https://www.terraform.io/downloads.html)
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

## 🛠️ Usage

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

Generated code
---

## 🤖 Automation: CI/CD and Drift Detection

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

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/your-username/your-repo-name/issues).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END
Corrected German README.md (Ready to copy)
Generated markdown
# Automatisierte AWS-Infrastruktur mit Terraform

Dieses Projekt demonstriert ein robustes, wiederholbares und versioniertes System zur Bereitstellung und Verwaltung von AWS-Infrastruktur mithilfe von Terraform. Es zeigt einen Infrastructure as Code (IaC)-Ansatz zur Provisionierung von Kernkomponenten wie Netzwerken (VPCs, Subnets), Sicherheit (IAM), Datenbanken (RDS) und skalierbaren Rechenressourcen (EC2).

Die Kernphilosophie besteht darin, Infrastruktur wie Software zu behandeln: in Git versioniert, durch automatisierte CI/CD-Pipelines bereitgestellt und für maximale Wiederverwendbarkeit und Wartbarkeit strukturiert.

---

## 📋 Inhaltsverzeichnis

*   [Wichtige Merkmale](#-wichtige-merkmale)
*   [Architekturübersicht](#-architekturübersicht)
*   [Erste Schritte](#-erste-schritte)
    *   [Voraussetzungen](#voraussetzungen)
    *   [Installation & Einrichtung](#installation--einrichtung)
*   [Verwendung](#-verwendung)
    *   [Bereitstellung der Infrastruktur](#bereitstellung-der-infrastruktur)
    *   [Beispiel: Erstellen eines VM-Clusters](#beispiel-erstellen-eines-vm-clusters)
*   [Projektstruktur](#-projektstruktur)
*   [Automatisierung: CI/CD und Drift-Erkennung](#-automatisierung-cicd-und-drift-erkennung)
*   [Mitwirken](#-mitwirken)
*   [Lizenz](#-lizenz)

---

## ✨ Wichtige Merkmale

*   **Deklarative Infrastructure as Code:** Definiert die gesamte AWS-Infrastruktur in lesbarer HCL (HashiCorp Configuration Language), wodurch manuelle Konfigurationsfehler vermieden werden.
*   **Modular und Wiederverwendbar:** Verwendet Terraform-Module für Komponenten wie VPCs und RDS, was die Architektur sauber und leicht skalierbar macht.
*   **Multi-Environment-Management:** Nutzt Terraform Workspaces, um verschiedene Umgebungen (`dev`, `staging`, `prod`) mit derselben Codebasis zu verwalten und Konsistenz zu gewährleisten.
*   **Skalierbare Bereitstellung von VM-Clustern:** Erstellt durch einfache Anpassung von Variablen eine beliebige Anzahl von konfigurierten virtuellen Maschinen aus einem "Golden Image".
*   **Automatisierte CI/CD-Pipeline:** Integriert sich in CI/CD-Tools (z. B. GitHub Actions), um Infrastrukturänderungen automatisch zu validieren, zu planen und anzuwenden.
*   **Proaktive Drift-Erkennung:** Beinhaltet einen automatisierten Mechanismus, um manuelle Änderungen an der Infrastruktur zu erkennen und sicherzustellen, dass die Live-Umgebung niemals von ihrer Code-Definition abweicht.

---

## 🏛️ Architekturübersicht

Dieses Projekt verwendet Terraform, um den Lebenszyklus von AWS-Ressourcen zu verwalten.

1.  **Module:** Die Infrastruktur ist in wiederverwendbare **Module** (z. B. `vpc`, `iam`, `ec2`) unterteilt. Dies hält die Root-Konfiguration übersichtlich und ermöglicht die Wiederverwendung von Modulen in verschiedenen Projekten.
2.  **Workspaces:** Um separate Umgebungen (`dev`, `prod`) zu verwalten, werden Terraform **Workspaces** verwendet. Jeder Workspace hat eine eigene State-Datei, wodurch sichergestellt wird, dass Änderungen in einer Entwicklungsumgebung die Produktion nicht beeinträchtigen.
3.  **State Management:** Der Terraform-Zustand (State) wird remote und sicher in einem AWS S3-Bucket gespeichert. Das State-Locking wird über DynamoDB aktiviert, um Konflikte bei der Zusammenarbeit im Team zu vermeiden.

---

## 🚀 Erste Schritte

Befolgen Sie diese Anweisungen, um eine Kopie des Projekts auf Ihrem lokalen Rechner für Entwicklungs- und Testzwecke zum Laufen zu bringen.

### Voraussetzungen

Stellen Sie sicher, dass Sie die folgenden Tools installiert und konfiguriert haben:

*   **Terraform v1.0+:** [Terraform herunterladen](https://www.terraform.io/downloads.html)
*   **AWS CLI:** [AWS CLI installieren](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*   **Konfigurierte AWS-Anmeldeinformationen:** Ihre AWS-Zugangsdaten müssen konfiguriert sein, damit Terraform auf Ihr Konto zugreifen kann. Sie können dies tun, indem Sie `aws configure` ausführen.

### Installation & Einrichtung

1.  **Klonen Sie das Repository:**
    ```sh
    git clone https://github.com/ihr-benutzername/ihr-repo-name.git
    cd ihr-repo-name
    ```

2.  **Initialisieren Sie Terraform:**
    Dieser Befehl initialisiert das Backend, lädt Provider-Plugins herunter und richtet die Module ein.
    ```sh
    terraform init
    ```

---

## 🛠️ Verwendung

### Bereitstellung der Infrastruktur

1.  **Wählen Sie einen Workspace aus:**
    Es ist Best Practice, für jede Umgebung einen eigenen Workspace zu erstellen.
    ```sh
    # Erstellt einen neuen 'dev'-Workspace und wechselt dorthin
    terraform workspace new dev
    ```

2.  **Überprüfen Sie den Ausführungsplan:**
    Führen Sie `terraform plan` aus, um zu sehen, welche Änderungen an Ihrer Infrastruktur vorgenommen werden. Dies ist eine sichere Methode, um Ihre Arbeit vor der Anwendung zu überprüfen.
    ```sh
    # Erstellt einen Plan mit den Variablen für die dev-Umgebung
    terraform plan -var-file="environments/dev.tfvars"
    ```

3.  **Wenden Sie die Änderungen an:**
    Wenn der Plan akzeptabel ist, wenden Sie ihn an, um die Infrastruktur zu erstellen.
    ```sh
    # Wendet den Plan an
    terraform apply -var-file="environments/dev.tfvars"
    ```

### Beispiel: Erstellen eines VM-Clusters

Um einen Cluster von 15 Windows Server 2019 VMs zu erstellen, ändern Sie einfach Ihre Variablendatei (`.tfvars`) und wenden die Konfiguration an.

1.  **Definieren Sie Ihren Cluster in `dev.tfvars`:**
    ```terraform
    # environments/dev.tfvars

    # Legt die gewünschte Anzahl an VMs fest
    vm_count = 15
    
    # Gibt die ID des vordefinierten "Golden Image" AMI an
    golden_ami_id = "ami-0a1b2c3d4e5f67890" 
    
    # Legt den Instanztyp fest (CPU/RAM)
    instance_type = "t3.large"
    
    # Definiert ein Namenspräfix für die VMs
    vm_name_prefix = "DC"
    ```

2.  **Wenden Sie die Konfiguration an:**
    Terraform erstellt automatisch 15 EC2-Instanzen mit den Namen `DC-1`, `DC-2`, usw., jede mit dem spezifizierten Betriebssystem und der Hardwarekonfiguration.
    ```sh
    terraform apply -var-file="environments/dev.tfvars"
    ```

---

## 📂 Projektstruktur

Das Repository ist so organisiert, dass es Modularität und Übersichtlichkeit fördert.
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Markdown
IGNORE_WHEN_COPYING_END

.
├── main.tf # Root-Modul - Haupteinstiegspunkt
├── variables.tf # Root-Variablendefinitionen
├── outputs.tf # Root-Ausgabewerte
├── terraform.tf # Terraform-Backend- und Provider-Konfiguration
├── environments/ # Umgebungsspezifische Variablendateien
│ ├── dev.tfvars
│ └── prod.tfvars
└── modules/ # Wiederverwendbare Infrastruktur-Module
├── vpc/ # VPC, Subnets, IGW, NAT Gateway
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── ec2-instance/ # EC2-Instanz-Cluster-Modul
│ ├── main.tf
│ └── ...
└── rds/ # RDS-Datenbank-Modul
├── main.tf
└── ...

Generated code
---

## 🤖 Automatisierung: CI/CD und Drift-Erkennung

Dieses Projekt ist für die Verwaltung durch eine CI/CD-Pipeline konzipiert.

**CI-Pipeline (bei Pull-Request):**
1.  **`terraform fmt -check`**: Überprüft, ob der gesamte Code korrekt formatiert ist.
2.  **`terraform validate`**: Prüft die Konfiguration auf Syntaxfehler.
3.  **`terraform plan`**: Erstellt einen Ausführungsplan und postet ihn als Kommentar im Pull-Request zur Überprüfung durch Kollegen. Es werden keine Änderungen angewendet.

**CD-Pipeline (bei Merge in `main`):**
1.  **`terraform apply -auto-approve`**: Wendet die Änderungen automatisch auf die Produktionsumgebung an.

**Infrastruktur-Drift-Erkennung:**
*   Ein geplanter Job führt täglich `terraform plan` für die Produktionsumgebung aus.
*   Wenn der Plan nicht leer ist (was bedeutet, dass eine manuelle Änderung erkannt wurde), wird eine Benachrichtigung an das Betriebsteam ausgelöst.
*   Dies stellt sicher, dass der Zustand der Infrastruktur niemals vom Master-Branch abweicht und seine Integrität gewahrt bleibt.

---

## 🤝 Mitwirken

Beiträge, Fehlerberichte und Funktionswünsche sind willkommen! Besuchen Sie gerne die [Issues-Seite](https://github.com/ihr-benutzername/ihr-repo-name/issues).

---

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe die Datei [LICENSE.md](LICENSE.md) für Details.
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END
