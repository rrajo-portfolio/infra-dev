param(
    [string]$ClusterName = "portfolio",
    [int]$ServerNodes = 1,
    [int]$AgentNodes = 2,
    [switch]$Recreate
)

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "El comando '$Name' no está instalado o no está en el PATH."
    }
}

Assert-Command -Name "k3d"

$existing = @()
try {
    $existing = k3d cluster list -o json | ConvertFrom-Json
} catch {
    $existing = @()
}

$cluster = $existing | Where-Object { $_.name -eq $ClusterName }

if ($cluster) {
    if (-not $Recreate.IsPresent) {
        Write-Host "El cluster '$ClusterName' ya existe. Usa -Recreate para eliminarlo y volver a crearlo." -ForegroundColor Yellow
        return
    }

    Write-Host "Eliminando cluster existente '$ClusterName'..." -ForegroundColor Yellow
    k3d cluster delete $ClusterName | Out-Null
}

Write-Host "Creando cluster '$ClusterName' (servers=$ServerNodes, agents=$AgentNodes)..." -ForegroundColor Cyan
k3d cluster create $ClusterName `
    --servers $ServerNodes `
    --agents $AgentNodes `
    --port "80:80@loadbalancer" `
    --port "443:443@loadbalancer" `
    --wait `
    --kubeconfig-switch-context | Out-Null

Write-Host "`nCluster listo. Contexto kubectl actual: $ClusterName" -ForegroundColor Green
Write-Host "Comandos útiles:"
Write-Host "  kubectl get nodes"
Write-Host "  kubectl config use-context k3d-$ClusterName"
Write-Host "Para eliminar el cluster: k3d cluster delete $ClusterName"
