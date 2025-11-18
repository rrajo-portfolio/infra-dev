param(
    [string]$Namespace = "portfolio"
)

kubectl create namespace $Namespace -o yaml --dry-run=client | kubectl apply -f -

helm dependency update ./portfolio-stack | Out-Null

helm upgrade --install portfolio-infra ./portfolio-infra -n $Namespace
helm upgrade --install portfolio-stack ./portfolio-stack -n $Namespace -f ./values-dev.yaml
