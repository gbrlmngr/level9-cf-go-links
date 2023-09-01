# Terraform providers
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Cloudflare-related variables
variable "cf_account_id" {
  description = "Cloudflare Account ID for the worker"
  type        = string
  sensitive   = true
}

variable "cf_api_token" {
  description = "Cloudflare API token used for generating resources"
  type        = string
  sensitive   = true
}

variable "cf_zone_id" {
  description = "Cloudflare Zone ID for the worker domain"
  type        = string
  sensitive   = true
}

variable "cf_worker_name" {
  description = "Name of the Cloudflare worker"
  type        = string
  default     = "level9-go-links-worker"
}

# Cloudflare provider configuration
provider "cloudflare" {
  api_token = var.cf_api_token
}

# Cloudflare KV go links namespace
resource "cloudflare_workers_kv_namespace" "go_links_store" {
  account_id = var.cf_account_id
  title      = "go-links"
}

# Cloudflare worker that manages the redirects
resource "cloudflare_worker_script" "go_links_worker" {
  account_id = var.cf_account_id
  name       = var.cf_worker_name
  content    = file("../dist/index.js")
  module     = true

  kv_namespace_binding {
    name         = "GO_LINKS"
    namespace_id = cloudflare_workers_kv_namespace.go_links_store.id
  }
}

# Cloudflare DNS configuration for go.level9.gg subdomain
resource "cloudflare_worker_domain" "go_links_dns" {
  account_id = var.cf_account_id
  zone_id    = var.cf_zone_id
  hostname   = "go.level9.gg"
  service    = cloudflare_worker_script.go_links_worker.name
}

# Cloudflare worker route configuration
resource "cloudflare_worker_route" "go_links_route" {
  zone_id     = var.cf_zone_id
  pattern     = "go.level9.gg/*"
  script_name = cloudflare_worker_script.go_links_worker.name
}

# Essential go links KV entries
resource "cloudflare_workers_kv" "go_link_discord" {
  account_id   = var.cf_account_id
  namespace_id = cloudflare_workers_kv_namespace.go_links_store.id
  key          = "discord"
  value        = "https://discord.com/invite/UBsGmgcjzA"
}

resource "cloudflare_workers_kv" "go_link_status" {
  account_id   = var.cf_account_id
  namespace_id = cloudflare_workers_kv_namespace.go_links_store.id
  key          = "status"
  value        = "https://stats.uptimerobot.com/YNKkZtDvw3"
}

resource "cloudflare_workers_kv" "go_link_steam" {
  account_id   = var.cf_account_id
  namespace_id = cloudflare_workers_kv_namespace.go_links_store.id
  key          = "steam"
  value        = "https://steamcommunity.com/groups/level9gg"
}
