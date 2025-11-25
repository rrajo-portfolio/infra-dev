# Portfolio Helm Assets

## Purpose
Mirrors the Helm charts shipped in the dedicated `helm` repository so the infrastructure mono-repo can demonstrate Kubernetes readiness without leaving the infra-dev workspace. Recruiters can inspect the same templates Jenkins references when describing deployment strategies.

## Technology Focus
- Charts for catalog, users, orders, gateway, and notification services to showcase how each microservice exposes configuration, probes, and secrets in Kubernetes.
- `portfolio-infra` definitions for shared databases, Kafka, Elasticsearch, Kibana, Prometheus, Grafana, Mailhog, and Keycloak to prove the platform owns its supporting systems.
- Umbrella configuration plus helper scripts (such as `install-all.ps1`) that summarize how namespaces, image tags, and ingress endpoints are coordinated during a release.
