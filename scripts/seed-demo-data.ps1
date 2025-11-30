param(
  [string]$GatewayUrl = "http://localhost:8085/api",
  [string]$TokenUrl = "http://localhost:7080/auth/realms/portfolio/protocol/openid-connect/token",
  [string]$Username = "portfolio-admin",
  [string]$Password = "Password123!",
  [string]$ClientId = "portfolio-frontend"
)

function Get-AccessToken {
  $body = "grant_type=password&client_id=$ClientId&username=$Username&password=$Password"
  $response = Invoke-RestMethod -Method Post -Uri $TokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body
  return $response.access_token
}

$script:Token = Get-AccessToken
Write-Host "Obtained Keycloak token for $Username"

function Invoke-Gateway {
  param(
    [string]$Method,
    [string]$Path,
    $Body
  )

  $headers = @{ Authorization = "Bearer $script:Token" }
  if ($Body) {
    $json = $Body | ConvertTo-Json -Depth 6
    return Invoke-RestMethod -Method $Method -Uri ($GatewayUrl + $Path) -Headers $headers -ContentType "application/json" -Body $json
  }
  else {
    return Invoke-RestMethod -Method $Method -Uri ($GatewayUrl + $Path) -Headers $headers
  }
}

$ProductCurrency = "EUR"

$productSamples = @(
  @{ name = "Spring Boot Starter Pack"; sku = "SKU1001"; description = "Kit de microservicios base para entrevistas."; price = 129.99; currency = $ProductCurrency; stockQuantity = 120; tags = @("spring", "starter", "microservices") },
  @{ name = "Kafka Event Mesh"; sku = "SKU1002"; description = "Topolog\u00EDa de eventos para cat\u00E1logos y pedidos."; price = 249.00; currency = $ProductCurrency; stockQuantity = 45; tags = @("kafka", "events") },
  @{ name = "Keycloak Realm Premium"; sku = "SKU1003"; description = "Realm portfolio configurado con flujos enterprise."; price = 89.00; currency = $ProductCurrency; stockQuantity = 80; tags = @("security", "sso") },
  @{ name = "DevOps Pipeline Blueprint"; sku = "SKU1004"; description = "Pipeline Jenkins declarativo con stages paralelos."; price = 159.00; currency = $ProductCurrency; stockQuantity = 60; tags = @("jenkins", "cicd") },
  @{ name = "Observabilidad Pack"; sku = "SKU1005"; description = "Dashboards Prometheus + Grafana listos para importar."; price = 199.00; currency = $ProductCurrency; stockQuantity = 35; tags = @("observability", "grafana") },
  @{ name = "Mailhog Email Templates"; sku = "SKU1006"; description = "Plantillas para notificaciones de \u00F3rdenes."; price = 59.00; currency = $ProductCurrency; stockQuantity = 150; tags = @("notification") },
  @{ name = "Elasticsearch Analyzer Kit"; sku = "SKU1007"; description = "Configuraci\u00F3n para b\u00FAsquedas full-text multilenguaje."; price = 139.00; currency = $ProductCurrency; stockQuantity = 90; tags = @("search", "elasticsearch") },
  @{ name = "NGINX Gateway Legacy"; sku = "SKU1008"; description = "Config paralela a Spring Cloud Gateway para comparar enfoques."; price = 49.00; currency = $ProductCurrency; stockQuantity = 210; tags = @("gateway") },
  @{ name = "Helm Charts Bundle"; sku = "SKU1009"; description = "Charts para catalog, users y orders con values listos."; price = 189.00; currency = $ProductCurrency; stockQuantity = 55; tags = @("helm", "k8s") },
  @{ name = "Portfolio Notification Center"; sku = "SKU1010"; description = "Servicio de notificaciones basado en RabbitMQ."; price = 119.00; currency = $ProductCurrency; stockQuantity = 70; tags = @("rabbitmq", "notifications") },
  @{ name = "API Gateway Filters"; sku = "SKU1011"; description = "Colecci\u00F3n de filtros globales y circuit breakers."; price = 149.00; currency = $ProductCurrency; stockQuantity = 65; tags = @("gateway", "resilience") },
  @{ name = "Keycloak Theme Pack"; sku = "SKU1012"; description = "Tema personalizado con branding Portfolio."; price = 79.00; currency = $ProductCurrency; stockQuantity = 85; tags = @("security", "ux") },
  @{ name = "Users Microservice Booster"; sku = "SKU1013"; description = "Scripts de validaci\u00F3n y purgas programadas."; price = 139.00; currency = $ProductCurrency; stockQuantity = 55; tags = @("users", "scheduler") },
  @{ name = "Orders Analytics Pack"; sku = "SKU1014"; description = "KPIs y consultas para monitorear ventas."; price = 169.00; currency = $ProductCurrency; stockQuantity = 48; tags = @("analytics", "orders") },
  @{ name = "Docker Compose Lab"; sku = "SKU1015"; description = "Lab completo para correr el stack on-prem."; price = 99.00; currency = $ProductCurrency; stockQuantity = 95; tags = @("docker") },
  @{ name = "Security Hardening Checklist"; sku = "SKU1016"; description = "Checklist de pr\u00E1cticas OAuth2 + JWT."; price = 59.00; currency = $ProductCurrency; stockQuantity = 140; tags = @("security") },
  @{ name = "API-First Toolkit"; sku = "SKU1017"; description = "Plantillas OpenAPI y scripts de generaci\u00F3n."; price = 129.00; currency = $ProductCurrency; stockQuantity = 77; tags = @("openapi", "api-first") },
  @{ name = "CI Smoke Tests Pack"; sku = "SKU1018"; description = "Smoke tests para Docker Compose y servicios clave."; price = 149.00; currency = $ProductCurrency; stockQuantity = 66; tags = @("testing", "ci") },
  @{ name = "Kubernetes GitOps Starter"; sku = "SKU1019"; description = "Base para ArgoCD y despliegues declarativos."; price = 219.00; currency = $ProductCurrency; stockQuantity = 32; tags = @("gitops", "kubernetes") },
  @{ name = "Portfolio Frontend UX"; sku = "SKU1020"; description = "Componentes Angular con Keycloak integrado."; price = 129.00; currency = $ProductCurrency; stockQuantity = 88; tags = @("angular", "keycloak") }
)

Write-Host "Seeding products..."
foreach ($product in $productSamples) {
  try {
    Invoke-Gateway -Method Post -Path "/catalog/products" -Body $product | Out-Null
  }
  catch {
    Write-Warning "Product $($product.sku) skipped: $($_.Exception.Message)"
  }
}

$productList = (Invoke-Gateway -Method Get -Path "/catalog/products?size=100").content
if (-not $productList) {
  Write-Warning "No se pudo crear ning\u00FAn producto. Revisa los logs de catalog-service."
  exit 1
}
Write-Host "Products available:" $productList.Count

$userSamples = @(
  @{ fullName = "Alicia Romero"; email = "alicia.romero@portfolio.local"; headline = "Cloud Architect"; skills = @("spring", "aws", "terraform") },
  @{ fullName = "Bernardo D\u00EDaz"; email = "bernardo.diaz@portfolio.local"; headline = "Backend Senior"; skills = @("java", "kafka") },
  @{ fullName = "Carla Pe\u00F1a"; email = "carla.pena@portfolio.local"; headline = "DevOps Engineer"; skills = @("jenkins", "docker", "kubernetes") },
  @{ fullName = "Diego Santos"; email = "diego.santos@portfolio.local"; headline = "Site Reliability"; skills = @("prometheus", "grafana") },
  @{ fullName = "Elena Vargas"; email = "elena.vargas@portfolio.local"; headline = "Product Owner"; skills = @("agile") },
  @{ fullName = "Fernando Ruiz"; email = "fernando.ruiz@portfolio.local"; headline = "Solutions Engineer"; skills = @("openapi", "keycloak") },
  @{ fullName = "Gabriela L\u00F3pez"; email = "gabriela.lopez@portfolio.local"; headline = "Lead Developer"; skills = @("angular", "spring") },
  @{ fullName = "H\u00E9ctor Molina"; email = "hector.molina@portfolio.local"; headline = "Integration Specialist"; skills = @("webclient", "rest") },
  @{ fullName = "In\u00E9s Castillo"; email = "ines.castillo@portfolio.local"; headline = "QA Automation"; skills = @("testing", "playwright") },
  @{ fullName = "Javier Ortega"; email = "javier.ortega@portfolio.local"; headline = "Microservices Coach"; skills = @("microservices", "ddd") },
  @{ fullName = "Karina M\u00E9ndez"; email = "karina.mendez@portfolio.local"; headline = "Security Engineer"; skills = @("oauth2", "jwt") },
  @{ fullName = "Luis Cabrera"; email = "luis.cabrera@portfolio.local"; headline = "Support Lead"; skills = @("ops", "monitoring") },
  @{ fullName = "Portfolio Demo User"; email = "user@portfolio.local"; headline = "Demo Buyer"; skills = @("checkout", "demo") }
)

Write-Host "Seeding users..."
foreach ($user in $userSamples) {
  try {
    Invoke-Gateway -Method Post -Path "/users" -Body $user | Out-Null
  }
  catch {
    Write-Warning "User $($user.email) skipped: $($_.Exception.Message)"
  }
}

$userList = (Invoke-Gateway -Method Get -Path "/users?size=100").content
if (-not $userList) {
  Write-Warning "No se pudo crear ning\u00FAn usuario. Revisa los logs de users-service."
  exit 1
}
Write-Host "Users available:" $userList.Count

function Get-RandomItems {
  param(
    [int]$Count
  )
  $indices = Get-Random -InputObject (0..($productList.Count - 1)) -Count $Count
  return $indices | ForEach-Object {
    $productList[$_]
  }
}

$orderPayloads = @()
for ($i = 0; $i -lt 10; $i++) {
  $user = $userList[$i % $userList.Count]
  $items = @()
  $selectedProducts = Get-RandomItems -Count 2
  foreach ($p in $selectedProducts) {
    $items += @{
      productId = $p.id
      quantity = Get-Random -Minimum 1 -Maximum 4
    }
  }
  $orderPayloads += @{
    userId = $user.id
    currency = $ProductCurrency
    notes = "Pedido demo #$($i + 1) generado autom\u00E1ticamente."
    items = $items
  }
}

Write-Host "Seeding orders..."
foreach ($order in $orderPayloads) {
  try {
    Invoke-Gateway -Method Post -Path "/orders" -Body $order | Out-Null
  }
  catch {
    Write-Warning "Order for user $($order.userId) skipped: $($_.Exception.Message)"
  }
}

$orderCount = (Invoke-Gateway -Method Get -Path "/orders?size=50").content.Count
Write-Host "Orders available:" $orderCount
Write-Host "Seed completed."
