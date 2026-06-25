locals {
  default_tags = {
    environment = var.environment
    prefix      = var.prefix
    created_by  = "terraform"
  }

  tags = merge(local.default_tags, var.tags)

  cost_management_tags = {
    cost_center = "IT-AVD"
    workload    = "azure-virtual-desktop"
    created_by  = "terraform"
  }

  enhanced_tags = merge(local.tags, local.cost_management_tags)
}

# =============================================================================
# NETWORK
# =============================================================================

module "network" {
  source = "./modules/network"

  prefix                = var.prefix
  environment           = var.environment
  location              = var.location
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix

  delete_network_watcher_rg = var.delete_network_watcher_rg

  tags          = local.tags
  enhanced_tags = local.enhanced_tags
}

# =============================================================================
# SERVICES (AVD Core)
# =============================================================================

module "services" {
  source = "./modules/services"

  prefix                              = var.prefix
  environment                         = var.environment
  location                            = var.location
  deployment_type                     = var.deployment_type
  max_session_limit                   = var.max_session_limit
  load_balancer_type                  = var.load_balancer_type
  personal_desktop_assignment_type    = var.personal_desktop_assignment_type
  registration_token_expiration_hours = var.registration_token_expiration_hours
  published_applications              = var.published_applications
  security_principal_object_ids       = var.security_principal_object_ids

  tags          = local.tags
  enhanced_tags = local.enhanced_tags
}

# =============================================================================
# MONITORING
# =============================================================================

module "monitoring" {
  source = "./modules/monitoring"
  count  = var.enable_monitoring ? 1 : 0

  prefix                    = var.prefix
  environment               = var.environment
  location                  = var.location
  monitoring_retention_days = var.monitoring_retention_days

  resource_group_name    = module.services.resource_group_name
  host_pool_id           = module.services.host_pool_id
  host_pool_name         = module.services.host_pool_name
  workspace_id           = module.services.workspace_id
  workspace_name         = module.services.workspace_name
  application_group_id   = module.services.application_group_id
  application_group_name = module.services.application_group_name

  tags = local.tags
}

# =============================================================================
# SESSION HOSTS
# =============================================================================

module "session_hosts" {
  source = "./modules/session-hosts"

  prefix                        = var.prefix
  environment                   = var.environment
  location                      = var.location
  session_host_count            = var.session_host_count
  vm_size                       = var.vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  marketplace_gallery_image_sku = var.marketplace_gallery_image_sku
  configuration_zip_file        = var.configuration_zip_file

  security_principal_object_ids = var.security_principal_object_ids

  subnet_id          = module.network.subnet_id
  host_pool_name     = module.services.host_pool_name
  host_pool_id       = module.services.host_pool_id
  registration_token = module.services.registration_token

  enable_monitoring        = var.enable_monitoring
  avd_session_hosts_dcr_id = var.enable_monitoring ? module.monitoring[0].data_collection_rule_id : null

  tags          = local.tags
  enhanced_tags = local.enhanced_tags

  depends_on = [module.services, module.monitoring]
}

# =============================================================================
# SCALING
# =============================================================================

module "scaling" {
  source = "./modules/scaling"
  count  = var.enable_scaling_plans && contains(["pooled_desktop", "pooled_remoteapp"], var.deployment_type) ? 1 : 0

  prefix                 = var.prefix
  environment            = var.environment
  location               = var.location
  scaling_plan_schedules = var.scaling_plan_schedules

  resource_group_name = module.services.resource_group_name
  host_pool_id        = module.services.host_pool_id

  tags = local.tags
}

# =============================================================================
# DASHBOARD
# =============================================================================

module "dashboard" {
  source = "./modules/dashboard"
  count  = (var.enable_cost_alerts || var.enable_dashboards) ? 1 : 0

  prefix      = var.prefix
  environment = var.environment
  location    = var.location

  enable_cost_alerts         = var.enable_cost_alerts
  enable_dashboards          = var.enable_dashboards
  cost_alert_threshold       = var.cost_alert_threshold
  cost_alert_email           = var.cost_alert_email
  dashboard_refresh_interval = var.dashboard_refresh_interval
  deployment_type            = var.deployment_type

  resource_group_name        = module.services.resource_group_name
  resource_group_id          = module.services.resource_group_id
  host_pool_id               = module.services.host_pool_id
  log_analytics_workspace_id = var.enable_monitoring ? module.monitoring[0].log_analytics_workspace_id : ""

  tags = local.tags
}