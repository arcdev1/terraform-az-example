# Global variables for the project
variable "location" {
  type    = string
  default = "canadacentral"
}

variable "tags" {
  type = map(string)
}

# Resource Group
variable "resource_group_name" {
  type = string
}

# Log Analytics Workspace
variable "log_analytics_workspace_name" {
  type = string
}

variable "log_analytics_workspace_sku" {
  type = string
}

variable "log_analytics_workspace_retention_in_days" {
  default = 30
}

# Application Insights
variable "app_insights_name" {
  type = string
}

variable "app_insights_application_type" {
  type = string
}

# Application Service Plan 
variable "app_service_plan_web_name" {
  type = string
}
variable "app_service_plan_web_sku" {
  type = string
}
variable "app_service_plan_web_os" {
  type = string
}

# Web App
variable "app_webapp_name" {
  type = string
}
