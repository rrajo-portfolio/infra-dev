# Portfolio Helm Charts

## Structure
- `catalog-service/`, `users-service/`, `orders-service/`: individual charts para cada microservicio.
- `portfolio-infra/`: recursos compartidos (MySQL, Postgres, Keycloak, Kafka, Elasticsearch, Kibana, Prometheus, Grafana, Mailhog, Adminer).
- `portfolio-stack/`: umbrella chart que toma los tres servicios + gateway como dependencias.
- `values-dev.yaml`, `values-prod.yaml`: overlays de imágenes por entorno.
- `install-all.ps1`: script que actualiza dependencias y despliega `portfolio-infra` + `portfolio-stack`.

## Quick Start
```powershell
cd helm
./install-all.ps1 -Namespace portfolio
```
This updates dependencies and deploys the umbrella chart using `values-dev.yaml`.

To override container tags:
```bash
helm upgrade --install portfolio-stack ./portfolio-stack \
  --namespace portfolio \
  --set catalog-service.image.tag=2025.11.06 \
  --set users-service.image.tag=2025.11.06 \
  --set orders-service.image.tag=2025.11.06 \
  --set gateway-service.image.tag=2025.11.06
```

To install únicamente la infraestructura:
```bash
helm upgrade --install portfolio-infra ./portfolio-infra -n portfolio
```

Grafana incluye un dashboard `Portfolio Overview` (requests catalog/users/orders, errores, Kafka, JVM). Accede tras un port-forward:
```bash
kubectl port-forward svc/grafana 3000:3000 -n portfolio
```
Credenciales por defecto: `admin` / `admin`. Prometheus escucha en `http://prometheus:9090`.

## Publishing
1. Initialize a Git repository in this folder (`git init`, add remote `https://github.com/rrajo-portfolio/helm.git`).
2. `git add . && git commit -m "feat: add portfolio stack chart"`.
3. Push once the remote repository exists: `git push -u origin main`.
