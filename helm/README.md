# Portfolio Helm Assets

## Purpose
Mirrors the Helm charts shipped in the dedicated `helm` repository so the infrastructure mono-repo can demonstrate Kubernetes readiness without leaving the infra-dev workspace. Recruiters can inspect the same templates Jenkins references when describing deployment strategies.

## Technology Focus
- Charts for catalog, users, orders, gateway, and notification services to showcase how each microservice exposes configuration, probes, and secrets in Kubernetes.
- Chart for the Angular SPA so recruiters can browse the UI from the same cluster that runs the backend services.
- `portfolio-infra` definitions for shared databases, Kafka, Elasticsearch, Kibana, Prometheus, Grafana, Mailhog, and Keycloak to prove the platform owns its supporting systems.
- Umbrella configuration plus helper scripts (such as `install-all.ps1`) that summarize how namespaces, image tags, and ingress endpoints are coordinated during a release.

## Port-forwarding the Ingress
- Gateway and frontend templates now render Kubernetes `Ingress` objects (default class: `nginx`) with the hosts `gateway.localtest.me` and `frontend.localtest.me`.
- After installing an ingress controller, run `kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80` and keep the terminal open.
- Visit `http://frontend.localtest.me:8080` to use the SPA, while APIs and Keycloak remain at `http://gateway.localtest.me:8080`. Because `localtest.me` resolves to `127.0.0.1`, the browser reaches the cluster without editing `/etc/hosts`.
