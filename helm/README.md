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

Grafana incluye un dashboard `Portfolio Overview` (requests catalog/users/orders, errores, Kafka, JVM). Con el Ingress que trae el chart puedes abrir directamente:

- Grafana → http://grafana.localtest.me (credenciales `admin` / `admin`)
- Prometheus → http://prometheus.localtest.me

`*.localtest.me` resuelve a `127.0.0.1`, así que no necesitas editar el `hosts`.

## Publishing
1. Initialize a Git repository in this folder (`git init`, add remote `https://github.com/rrajo-portfolio/helm.git`).
2. `git add . && git commit -m "feat: add portfolio stack chart"`.
3. Push once the remote repository exists: `git push -u origin main`.

## k3d helper

Para levantar todo el stack en un cluster k3d local:

1. Crea el cluster:
   ```powershell
   cd scripts
   ./create-k3d-cluster.ps1 -ClusterName portfolio
   ```
   Agrega `-Recreate` si quieres destruir y crear de nuevo.
   > El script expone los puertos 80/443 del load balancer del cluster hacia tu host para que los hostnames `*.localtest.me` funcionen sin pasos extra.

2. Compila las imágenes Docker de los microservicios e impórtalas al cluster:
   ```powershell
   docker build -t rrajo-portfolio/catalog-service:latest ..\..\catalog-service
   # Repite para users/orders/gateway/notification
   k3d image import rrajo-portfolio/catalog-service:latest `
     rrajo-portfolio/users-service:latest `
     rrajo-portfolio/orders-service:latest `
     rrajo-portfolio/gateway-service:latest `
     rrajo-portfolio/notification-service:latest `
     -c portfolio
   ```

3. Instala la infraestructura y el stack:
   ```powershell
   cd ..
   ./install-all.ps1 -Namespace portfolio
   ```

4. Accede vía Ingress:
   - http://grafana.localtest.me (dashboard `Portfolio Overview`)
   - http://prometheus.localtest.me
   > Si prefieres otro hostname, ajusta los valores `grafana.ingress.*` y `prometheus.ingress.*`.

5. Elimina el cluster si ya no lo necesitas:
   ```powershell
   k3d cluster delete portfolio
   ```
