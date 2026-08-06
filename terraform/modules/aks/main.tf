resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project}-${var.environment}-${var.region_short}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project}-${var.environment}-${var.region_short}"
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_vm_size
    vnet_subnet_id      = var.aks_subnet_id
    os_disk_size_gb     = 30

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
  }

  tags = var.tags
}

# ── NiFi node pool ────────────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "nifi" {
  name                  = "nifi"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.nifi_node_vm_size
  node_count            = var.nifi_node_count
  vnet_subnet_id        = var.aks_subnet_id
  os_disk_size_gb       = 30

  node_labels = {
    "workload" = "nifi"
  }

  node_taints = ["workload=nifi:NoSchedule"]

  tags = var.tags
}
