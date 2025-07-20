# Automatisierte AWS-Infrastruktur mit Terraform

Dieses Projekt zeigt ein robustes, wiederverwendbares und versioniertes System zur Bereitstellung und Verwaltung von AWS-Infrastruktur mithilfe von Terraform. Es veranschaulicht einen Infrastructure-as-Code (IaC)-Ansatz zur Bereitstellung grundlegender Netzwerke (VPCs, Subnets), Sicherheit (IAM), Datenbanken (RDS) und skalierbaren Rechenressourcen (EC2).

Die Kernphilosophie besteht darin, Infrastruktur wie Software zu behandeln: versioniert in Git, über automatisierte CI/CD-Pipelines bereitgestellt und für maximale Wiederverwendbarkeit und Wartbarkeit strukturiert.

---

## 📋 Inhaltsverzeichnis

*   [Schlüsselmerkmale](#-schlüsselmerkmale)
*   [Architektübersicht](#-architektübersicht)
*   [Erste Schritte](#-erste-schritte)
    *   [Voraussetzungen](#voraussetzungen)
    *   [Installation und Einrichtung](#installation--einrichtung)
*   [Verwendung](#-verwendung)
    *   [Bereitstellen der Infrastruktur](#bereitstellen-der-infrastruktur)
    *   [Beispiel: Erstellen eines VM-Clusters](#beispiel-erstellen-eines-vm-clusters)
*   [Projektstruktur](#-projektstruktur)
*   [Automation: CI/CD und Drift-Erkennung](#-automation-cicd-und-drift-erkennung)
*   [Mitwirken](#-mitwirken)

---

##  Schlüsselmerkmale

*   **Deklarative Infrastruktur als Code:** Definiert die gesamte AWS-Infrastruktur in menschenlesbaren HCL-Dateien, um manuelle Konfigurationsfehler zu vermeiden.
*   **Modular und wiederverwendbar:** Nutzt Terraform-Module für Komponenten wie VPCs und RDS, um die Architektur sauber und skalierbar zu halten.
*   **Multi-Umgebung-Verwaltung:** Nutzt Terraform-Workspaces, um `dev`, `staging` und `prod`-Umgebungen mit demselben Codebase zu verwalten und Konsistenz sicherzustellen.
*   **Skalierbare VM-Cluster-Bereitstellung:** Erstellen Sie einfach beliebig viele konfigurierte virtuelle Maschinen aus einem "Golden Image" durch einfache Variablenänderungen.
*   **Automatisierte CI/CD-Pipeline:** Integriert mit CI/CD-Tools (z. B. GitHub Actions), um Infrastrukturänderungen automatisch zu validieren, zu planen und anzuwenden.
*   **Proaktive Drift-Erkennung:** Enthält ein automatisches System zur Erkennung manueller Änderungen an der Infrastruktur, um sicherzustellen, dass die Live-Umgebung niemals von ihrer Code-Definition abweicht.

---

##  Architektübersicht

Dieses Projekt verwendet Terraform, um das Lebenszyklusmanagement von AWS-Ressourcen zu verwalten.

1.  **Module:** Die Infrastruktur wird in wiederverwendbare **Module** (z. B. `vpc`, `iam`, `ec2`) unterteilt. Dies hält die Root-Konfiguration sauber und ermöglicht die Wiederverwendung der Module in verschiedenen Projekten.
2.  **Workspaces:** Um separate Umgebungen (`dev`, `prod`) zu verwalten, werden Terraform-**Workspaces** verwendet. Jeder Workspace hat seine eigene State-Datei, wodurch Änderungen in der Entwicklungsumgebung die Produktion nicht beeinflussen.
3.  **State-Verwaltung:** Terraforms State wird remote und sicher in einem AWS S3-Bucket gespeichert, wobei der State-Locking über DynamoDB aktiviert ist, um Konflikte bei der Teamarbeit zu verhindern.

---

##  Erste Schritte

Folgen Sie diesen Anweisungen, um eine Kopie des Projekts auf Ihrem lokalen Rechner für Entwicklung und Testzwecke zu starten.

### Voraussetzungen

Stellen Sie sicher, dass die folgenden Tools installiert und konfiguriert sind:

*   **Terraform v1.0+:** [Terraform herunterladen](https://www.terraform.io/downloads.html)
*   **AWS CLI:** [AWS CLI installieren](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*   **Konfigurierte AWS-Anmeldeinformationen:** Ihre AWS-Kontodaten müssen für Terraform konfiguriert sein. Sie können dies tun, indem Sie `aws configure` ausführen.

### Installation und Einrichtung

1.  **Klonen Sie das Repository:**
    ```sh
    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name
    ```

2.  **Terraform initialisieren:**
    Dieser Befehl initialisiert den Backend, lädt Provider-Plugins herunter und bereitet die Module vor.
    ```sh
    terraform init
    ```

---

##  Verwendung

### Bereitstellen der Infrastruktur

1.  **Workspace auswählen:**
    Es ist eine bewährte Praxis, einen Workspace für Ihre Umgebung zu erstellen.
    ```sh
    # Erstellen und Wechseln zu einem neuen 'dev'-Workspace
    terraform workspace new dev
    ```

2.  **Überprüfen Sie den Ausführungsplan:**
    Führen Sie `terraform plan` aus, um zu sehen, welche Änderungen an der Infrastruktur vorgenommen werden. Dies ist eine sichere Möglichkeit, Ihre Arbeit vor dem Anwenden zu prüfen.
    ```sh
    # Erstellen Sie einen Plan mit Variablen aus der dev-Umgebung
    terraform plan -var-file="environments/dev.tfvars"
    ```

3.  **Wenden Sie die Änderungen an:**
    Wenn der Plan akzeptabel ist, wenden Sie ihn an, um die Infrastruktur zu erstellen.
    ```sh
    # Wenden Sie den Plan an
    terraform apply -var-file="environments/dev.tfvars"
    ```

### Beispiel: Erstellen eines VM-Clusters

Um einen Cluster aus 15 Windows Server 2019-Virtuellen Maschinen zu erstellen, ändern Sie einfach Ihre Variablendatei (`.tfvars`) und wenden Sie sie an.

1.  **Definieren Sie Ihren Cluster in `dev.tfvars`:**
    ```terraform
    # environments/dev.tfvars

    # Legen Sie die gewünschte Anzahl von VMs fest
    vm_count = 15
    
    # Geben Sie die vorbereitete "Golden Image"-AMI-ID an
    golden_ami_id = "ami-0a1b2c3d4e5f67890" 
    
    # Geben Sie den Instanztyp (CPU/RAM) an
    instance_type = "t3.large"
    
    # Definieren Sie einen Namenspräfix für die VMs
    vm_name_prefix = "DC"
    ```

2.  **Wenden Sie die Konfiguration an:**
    Terraform erstellt automatisch 15 EC2-Instanzen mit dem Namen `DC-1`, `DC-2` usw., jeweils mit der angegebenen OS- und Hardware-Konfiguration.
    ```sh
    terraform apply -var-file="environments/dev.tfvars"
    ```

---

## 📂 Projektstruktur

Das Repository ist so organisiert, dass Modularität und Klarheit gefördert werden.

```text
.
├── main.tf # Root-Modul - Haupteintragspunkt
├── variables.tf # Root-Variable-Definitionen
├── outputs.tf # Root-Outputs
├── terraform.tf # Terraform-Backend und Provider-Konfiguration
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2-instance/
    │   ├── main.tf
    │   └── ...
    └── rds/
        ├── main.tf
        └── ...
```

---

##  Automation: CI/CD und Drift-Erkennung

Dieses Projekt ist für die Verwaltung durch eine CI/CD-Pipeline konzipiert.

**CI-Pipeline (bei Pull Request):**
1.  **`terraform fmt -check`**: Überprüft, ob alle Code-Dateien korrekt formatiert sind.
2.  **`terraform validate`**: Prüft auf Syntaxfehler in der Konfiguration.
3.  **`terraform plan`**: Erstellt einen Ausführungsplan und postet ihn als Kommentar zum Pull Request für die Peer-Review. Es werden keine Änderungen angewandt.

**CD-Pipeline (bei Merge in `main`):**
1.  **`terraform apply -auto-approve`**: Wendet die Änderungen automatisch in der Produktionsumgebung an.

**Infrastruktur-Drift-Erkennung:**
*   Ein geplanter Job führt `terraform plan` täglich gegen die Produktionsumgebung durch.
*   Wenn der Plan nicht leer ist (was bedeutet, dass eine manuelle Änderung erkannt wurde), löst er eine Benachrichtigung für das Operations-Team aus.
*   Dies stellt sicher, dass der Infrastruktur-Status niemals vom Master-Branch abweicht und seine Integrität gewährleistet.

---

##  Mitwirken

Mitwirkung, Probleme und Funktionanfragen sind willkommen! Sie können gerne die [Issues-Seite](https://github.com/your-username/your-repo-name/issues) überprüfen.
