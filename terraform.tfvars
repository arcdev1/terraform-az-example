# DEV ENVIRONMENT
# Make sure to run this in the default workspace
# terraform workspace select default

tags = {
  "client"      = "AAFC"
  "environment" = "dev"
  "project"     = "aafc-webapp"
}

resource_group_name = "webapp-dev-rg"

log_analytics_workspace_name              = "webapp-dev-laws"
log_analytics_workspace_sku               = "PerGB2018"
log_analytics_workspace_retention_in_days = 30

app_insights_name             = "webapp-dev-ai"
app_insights_application_type = "web"

app_service_plan_web_name = "webapp-dev-asp"
app_service_plan_web_sku  = "B1"
app_service_plan_web_os   = "Linux"

app_webapp_name = "webapp-dev-internal"

fn_storage_account_name             = "webappdevfnstorage"
fn_storage_account_tier             = "Standard"
fn_storage_account_replication_type = "LRS"
