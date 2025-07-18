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
Use code with caution.
Markdown
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
