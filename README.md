# NiFi DevOps Platform — CGX

Cross-region database sync architecture for China ↔ France.

## Stack
- **Terraform** — Infrastructure as Code (Azure)
- **Kubernetes (AKS)** — Container orchestration
- **Helm** — NiFi app packaging
- **ArgoCD** — GitOps continuous delivery
- **Apache NiFi** — Data flow & DB sync

## Repository Structure
\`\`\`
├── terraform/          # IaC — Azure infrastructure modules
│   ├── modules/        # Reusable child modules
│   └── environments/   # Per-region variable overrides
├── helm/               # Helm charts
│   ├── nifi/           # NiFi StatefulSet chart
│   └── monitoring/     # Prometheus chart
├── argocd/             # ArgoCD projects & applications
│   ├── projects/
│   └── apps/
└── docs/               # Architecture & setup docs
\`\`\`

## Regions
| Region | Azure Location | Short |
|--------|---------------|-------|
| France | francecentral | fr    |
| China  | chinaeast2    | cn    |
