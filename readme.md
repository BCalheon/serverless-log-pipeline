# 🚀 Serverless Log Intelligence Pipeline
### *Automated Cloud Infrastructure with LocalStack, Terraform, and Grafana*

This project provides a fully automated, local-first cloud environment for real-time log ingestion, processing, and observability. It utilizes **LocalStack** to simulate AWS services, ensuring a cost-effective development lifecycle while maintaining high-fidelity production parity.

---

> [!WARNING]
> ### 🧪 Laboratory & Sandbox Notice
> This project is designed strictly for **educational, laboratory, and sandbox purposes**. 
> * **Security:** Authentication is bypassed in Grafana (Anonymous Admin) and default "test" keys are used for AWS simulation to streamline the local developer experience.
> * **Production Use:** Do **not** deploy these configurations to a production environment without implementing robust IAM policies, secrets management (e.g., Azure Key Vault or AWS Secrets Manager), and secure authentication layers.

---

## 🏗️ Architecture Overview

The system follows a reactive, event-driven architecture designed for high scalability and decoupled processing:

1.  **Ingestion:** Log files are uploaded to an **Amazon S3** bucket.
2.  **Trigger:** S3 Event Notifications trigger an **AWS Lambda** function upon `.log` file creation.
3.  **Processing:** The Lambda (Python-based) extracts metadata and persists results in a **DynamoDB** table.
4.  **Observability:** Performance metrics (Invocations, Errors) are captured by **CloudWatch** and visualized in a pre-provisioned **Grafana** dashboard.

---

## 🛠️ Technical Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Cloud Simulation** | **LocalStack** | Emulates S3, Lambda, DynamoDB, IAM, and CloudWatch. |
| **IaC** | **Terraform** | Modular infrastructure management and lifecycle orchestration. |
| **Processing** | **Python (Lambda)** | Event-driven logic for data extraction and transformation. |
| **Persistence** | **DynamoDB** | NoSQL storage for high-performance log auditing. |
| **Observability** | **Grafana** | Provisioned-as-Code dashboards for real-time monitoring. |
| **Automation** | **Makefile** | Interactive CLI for environment bootstrapping and testing. |

---

## 🚦 Getting Started

### Prerequisites
* **Docker & Docker Compose**
* **Terraform** (>= 1.0.0)
* **AWS CLI v2**
* **Make** (standard on Linux/macOS)

### Installation
1.  Clone the repository:
    ```bash
    git clone [https://github.com/your-username/serverless-log-pipeline.git](https://github.com/your-username/serverless-log-pipeline.git)
    cd serverless-log-pipeline
    ```
2.  Launch the environment:
    ```bash
    make up
    ```

---

## ⚙️ Automation & Safety

The project features a **Safe-Apply** pipeline within the `Makefile` to prevent unintended infrastructure changes, demonstrating a mature approach to **DevOps principles**.

### Lifecycle Commands
* **`make up`**: The "Master" command. Performs a full bootstrap, generates a Terraform Plan, waits for user approval, and offers an optional stress test.
* **`make stress-test`**: Simulates sustained traffic with 3 waves of bursts to generate meaningful time-series data in the monitoring dashboard.
* **`make list-db`**: Verifies data persistence by scanning the DynamoDB table.

---

## 📊 Monitoring as Code

The **Grafana** instance is configured using **Immutable Provisioning**. This ensures that Data Sources and Dashboards are automatically available upon container startup without manual intervention.

* **Data Source:** Pre-configured for LocalStack CloudWatch using static keys.
* **Dashboard:** "Cloud Infrastructure - Service Monitor" provides a granular view of Lambda performance and system health.

---

## 🛡️ Infrastructure Resilience

* **Decoupled Design:** Services are isolated using a dedicated Docker network.
* **State Management:** Utilizes an S3 backend for Terraform state, mimicking professional cloud workflows.
* **Clean Environment:** Includes a comprehensive `.gitignore` and `clean` commands to ensure the repository remains free of transient logs and state files.