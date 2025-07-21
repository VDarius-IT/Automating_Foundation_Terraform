# Automatisierte AWS-Infrastruktur mit Terraform

Dieses Repository stellt ein produktionsreifes Framework für die Bereitstellung und Verwaltung von AWS-Infrastruktur mit Terraform bereit. Es folgt den Prinzipien von Infrastructure as Code (IaC), um ein versioniertes, wiederholbares und automatisiertes System für zentrale Cloud-Ressourcen zu schaffen.

Die Architektur ist modular, skalierbar und sicher konzipiert und eignet sich für die Verwaltung mehrerer Umgebungen (z. B. Entwicklung, Staging, Produktion) aus einer einzigen Codebasis heraus.

### Inhaltsverzeichnis

1.  [Hauptmerkmale](#hauptmerkmale)
2.  [Architekturübersicht](#architekturübersicht)
3.  [Voraussetzungen](#voraussetzungen)
4.  [Einrichtung und Konfiguration](#einrichtung-und-konfiguration)
5.  [Kern-Workflow](#kern-workflow)
6.  [Projektstruktur](#projektstruktur)
7.  [Automatisierung: CI/CD und Drift-Erkennung](#automatisierung-cicd-und-drift-erkennung)
8.  [Sicherheitsaspekte](#sicherheitsaspekte)
9.  [Kostenmanagement](#kostenmanagement)
10. [Mitwirken](#mitwirken)

---

### Hauptmerkmale

*   **Deklarative Infrastruktur:** Die gesamte AWS-Infrastruktur (VPC, EC2, RDS, IAM) wird in HCL definiert, was manuelle Konfigurationen überflüssig macht und Konsistenz gewährleistet.
*   **Modulare Architektur:** Komponenten wie Netzwerk und Rechenleistung sind in wiederverwendbaren Modulen gekapselt, was ein sauberes Design und eine Trennung der Verantwortlichkeiten fördert.
*   **Umgebungstrennung:** Terraform Workspaces werden verwendet, um separate Umgebungen (dev, prod) mit isolierten State-Dateien zu verwalten und so eine gegenseitige Beeinflussung zu verhindern.
*   **Sicherer Remote-State:** Nutzt ein S3-Backend für die Speicherung des Zustands (State) und eine DynamoDB-Tabelle für das State-Locking, was eine sichere Zusammenarbeit im Team ermöglicht.
*   **CI/CD-Automatisierung:** Integriert sich in GitHub Actions, um Infrastrukturänderungen zu validieren, zu planen und anzuwenden, wodurch ein "Code-Review-First"-Workflow erzwungen wird.
*   **Automatisierte Drift-Erkennung:** Ein geplanter Mechanismus erkennt automatisch manuelle Änderungen an der Infrastruktur und stellt sicher, dass die Live-Umgebung niemals von ihrer Code-Definition abweicht.

### Architekturübersicht

Das Projekt basiert auf drei grundlegenden Konzepten:

*   **Module:** Jedes einzelne Infrastruktur-Element (z. B. `vpc`, `ec2-cluster`) ist ein in sich geschlossenes Modul mit eigenen Eingaben, Ausgaben und einer README-Datei. Die Root-Datei `main.tf` fügt diese Module zusammen, um die gesamte Architektur zu erstellen.
*   **Remote-State:** Die Terraform-State-Datei, die Ressourcen Ihrer Konfiguration zuordnet, wird remote in einem AWS S3-Bucket gespeichert. Eine DynamoDB-Tabelle dient als Sperrmechanismus, um zu verhindern, dass mehrere Benutzer gleichzeitig `apply` ausführen und den Zustand beschädigen.
*   **Workspaces:** Ein Workspace entspricht einer Umgebung. Dies ermöglicht es, dieselbe Konfiguration für `dev` und `prod` bereitzustellen, während separate State-Dateien und unterschiedliche Variablenwerte für jede Umgebung verwendet werden.

### Voraussetzungen

Stellen Sie sicher, dass die folgenden Tools auf Ihrem lokalen Rechner installiert und konfiguriert sind:

*   **Terraform v1.4+**: [Terraform herunterladen](https://www.terraform.io/downloads.html)
*   **AWS CLI**: [AWS CLI installieren](https://aws.amazon.com/cli/)
*   **Konfigurierte AWS-Anmeldeinformationen**: Konfigurieren Sie Ihre Anmeldeinformationen, vorzugsweise über eine dedizierte IAM-Rolle oder einen Benutzer für Terraform.
    ```sh
    aws configure
    ```

### Einrichtung und Konfiguration

**1. Repository klonen**
```sh
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

**2. Terraform-Backend konfigurieren**

Dieses Projekt benötigt einen S3-Bucket und eine DynamoDB-Tabelle zur Verwaltung seines Zustands (State).

*   **S3-Bucket erstellen** (Ersetzen Sie `<ihr-eindeutiger-bucket-name>` und `<ihre-aws-region>`):
    ```sh
    aws s3 mb s3://<ihr-eindeutiger-bucket-name> --region <ihre-aws-region>
    ```

*   **DynamoDB-Tabelle erstellen** (Ersetzen Sie `<ihre-aws-region>`):
    ```sh
    aws dynamodb create-table \
        --table-name terraform-state-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region <ihre-aws-region>
    ```

*   **Backend-Konfiguration aktualisieren:**
    Ändern Sie die Datei `backend.tf` mit Ihrem Bucket-Namen, dem gewünschten Schlüssel für die State-Datei und Ihrer Region.

    ```hcl
    # backend.tf
    terraform {
      backend "s3" {
        bucket         = "<ihr-eindeutiger-bucket-name>" # DIES AKTUALISIEREN
        key            = "ihr-projekt/terraform.tfstate"
        region         = "<ihre-aws-region>"             # DIES AKTUALISIEREN
        dynamodb_table = "terraform-state-lock"
        encrypt        = true
      }
    }
    ```

**3. Terraform initialisieren**

Dieser Befehl lädt die erforderlichen Provider-Plugins herunter und initialisiert das konfigurierte Backend.
```sh
terraform init
```

### Kern-Workflow

Folgen Sie diesen Schritten, um die Infrastruktur bereitzustellen oder zu ändern.

**1. Workspace auswählen**

Erstellen Sie einen Workspace für Ihre Zielumgebung, falls dieser noch nicht existiert.
```sh
# Einen neuen 'dev'-Workspace erstellen und dorthin wechseln
terraform workspace new dev

# Oder einen bestehenden auswählen
terraform workspace select dev
```

**2. Ausführungsplan überprüfen**

Erstellen Sie einen Plan, um eine Vorschau der Änderungen zu erhalten, die Terraform vornehmen wird. Dies ist ein sicherer, schreibgeschützter Vorgang.
```sh
# Einen Plan mit Variablen aus der dev-Umgebung erstellen
terraform plan -var-file="environments/dev.tfvars"
```

**3. Änderungen anwenden**

Wenn der Plan akzeptabel ist, wenden Sie ihn an, um die Infrastruktur zu erstellen oder zu aktualisieren.
```sh
# Den Plan anwenden (Sie werden zur Bestätigung aufgefordert)
terraform apply -var-file="environments/dev.tfvars"
```

**4. Infrastruktur zerstören**

Um alle von dieser Konfiguration verwalteten Ressourcen zu entfernen und laufende Kosten zu vermeiden, führen Sie den Befehl `destroy` aus.
```sh
# Stellen Sie sicher, dass Sie sich zuerst im richtigen Workspace befinden
terraform workspace select dev

# Verwenden Sie dieselbe Variablendatei, um sicherzustellen, dass alle Ressourcen angesprochen werden
terraform destroy -var-file="environments/dev.tfvars"
```

### Projektstruktur

Das Repository ist so organisiert, dass Modularität, Übersichtlichkeit und die Trennung von Konfiguration und Logik gefördert werden.

```
.
├── .github/workflows/      # CI/CD-Pipeline-Definitionen (z.B. deploy.yml)
├── environments/           # Umgebungsspezifische Variablendateien
│   ├── dev.tfvars
│   └── prod.tfvars
├── modules/                # Wiederverwendbare Infrastruktur-Module
│   ├── vpc/                # Erstellt VPC, Subnetze, IGW, NAT-Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── ec2-cluster/        # Erstellt einen skalierbaren Cluster von EC2-Instanzen
│   └── rds/                # Erstellt eine RDS-Datenbankinstanz
├── main.tf                 # Root-Modul: Haupteinstiegspunkt, der andere Module aufruft
├── variables.tf            # Root-Variablendefinitionen
├── outputs.tf              # Root-Ausgaben (z.B. RDS-Endpunkt, LB-DNS)
├── backend.tf              # Terraform-Backend-Konfiguration
└── .gitignore              # Zu ignorierende Dateien und Verzeichnisse
```

### Automatisierung: CI/CD und Drift-Erkennung

**CI-Pipeline (bei Pull-Request)**
Die Pipeline in `.github/workflows/` wird bei Pull-Requests auf den `main`-Branch ausgelöst und führt die folgenden Prüfungen durch:
1.  `terraform fmt -check`: Überprüft, ob der HCL-Code korrekt formatiert ist.
2.  `terraform init`: Initialisiert das Backend und die Provider.
3.  `terraform validate`: Prüft auf Syntaxfehler.
4.  `terraform plan`: Erstellt einen Ausführungsplan und postet ihn im PR zur Begutachtung durch Kollegen (Peer-Review). Es werden keine Änderungen angewendet.

**CD-Pipeline (bei Merge in `main`)**
Nach dem Mergen eines Pull-Requests in den `main`-Branch wendet die Pipeline die Änderungen automatisch auf die Produktionsumgebung an:
1.  `terraform workspace select prod`
2.  `terraform apply -auto-approve`

**Infrastruktur-Drift-Erkennung**
Eine geplante GitHub Action läuft täglich für die Produktionsumgebung:
1.  Sie führt einen `terraform plan` aus.
2.  Wenn der Plan nicht leer ist (was auf eine manuelle Änderung in der AWS-Konsole hindeutet), wird ein Alarm ausgelöst, um das Betriebsteam zu benachrichtigen. Dies stellt sicher, dass der Zustand der Infrastruktur niemals vom `main`-Branch abweicht.

### Sicherheitsaspekte

*   **Prinzip der geringsten Rechte (Least Privilege):** IAM-Rollen und -Richtlinien sind so konfiguriert, dass sie nur die minimal erforderlichen Berechtigungen für den Betrieb der Dienste gewähren. Der IAM-Benutzer/die IAM-Rolle, die Terraform ausführt, sollte ebenfalls eingeschränkt sein.
*   **Verwaltung von Geheimnissen (Secrets Management):** Sensible Daten wie Datenbankpasswörter oder API-Schlüssel sollten **nicht** in `.tfvars`-Dateien gespeichert werden. Integrieren Sie einen Dienst wie AWS Secrets Manager oder HashiCorp Vault.
*   **Netzwerksicherheit:** Security Groups werden verwendet, um den Datenverkehr zwischen Ressourcen zu steuern, wobei standardmäßig eine "deny-all"-Haltung für eingehenden Verkehr gilt.
*   **Sicherheit der State-Datei:** Das S3-Backend ist so konfiguriert, dass die State-Datei im Ruhezustand (at rest) verschlüsselt wird. Der Zugriff sollte über IAM-Richtlinien streng eingeschränkt werden.

### Kostenmanagement

Beachten Sie, dass die Bereitstellung dieser Infrastruktur Kosten auf Ihrem AWS-Konto verursacht.
*   **Hauptkostentreiber:** EC2-Instanzen, RDS-Datenbanken, NAT-Gateways und Datenübertragung sind die Hauptkostenquellen.
*   **Kosten schätzen:** Verwenden Sie den [AWS Pricing Calculator](https://calculator.aws/), um die monatlichen Kosten vor einer produktiven Bereitstellung abzuschätzen.
*   **Aufräumen:** Um laufende Kosten zu vermeiden, führen Sie immer `terraform destroy` aus, wenn Sie mit dem Experimentieren fertig sind.

### Mitwirken

Beiträge, Problemmeldungen (Issues) und Funktionswünsche sind willkommen. Bitte eröffnen Sie ein Issue, um Ihre Ideen zu diskutieren, oder reichen Sie einen Pull-Request mit Ihren vorgeschlagenen Änderungen ein.
