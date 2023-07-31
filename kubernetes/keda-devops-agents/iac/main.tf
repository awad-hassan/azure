resource "azurerm_resource_group" "build-agent-rg" {
  name     = "dev-fab-ba-rg-uk-01"
  location = "UK South"
}

resource "azurerm_container_registry" "build-agent-registry" {
  name                = "devfabacrbauk01"
  resource_group_name = azurerm_resource_group.build-agent-rg.name
  location            = azurerm_resource_group.build-agent-rg.location
  sku                 = "Basic"
  admin_enabled       = "true"
}

resource "azurerm_kubernetes_cluster" "build-agent-cluster" {
  name                = "dev-fab-ba-aks-uk-01"
  location            = azurerm_resource_group.build-agent-rg.location
  resource_group_name = azurerm_resource_group.build-agent-rg.name
  dns_prefix          = "dev-fab-ba-aks-uk"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
  }
}

resource "azurerm_role_assignment" "acr-role-assignment" {
  principal_id                     = azurerm_kubernetes_cluster.build-agent-cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.build-agent-registry.id
  skip_service_principal_aad_check = true
}
