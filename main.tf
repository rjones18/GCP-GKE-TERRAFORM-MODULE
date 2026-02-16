resource "google_service_account" "nodes" {
  count        = var.create_node_service_account ? 1 : 0
  project      = var.project_id
  account_id   = "${var.name}-nodes"
  display_name = "${var.name} GKE node service account"
}

locals {
  node_sa_email = var.create_node_service_account ? google_service_account.nodes[0].email : var.node_service_account_email
}

resource "google_container_cluster" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location

  network    = var.network
  subnetwork = var.subnetwork

  # We manage node pools separately
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel # "REGULAR" is a common default
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Private cluster (common in companies)
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Optional: limit API server access
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr
          display_name = cidr_blocks.value.name
        }
      }
    }
  }

  # Common hardening defaults
  enable_intranode_visibility = var.enable_intranode_visibility

#   # Shielded Nodes is common for standard clusters
#   shielded_nodes {
#     enabled = var.enable_shielded_nodes
#   }

#   # Basic maintenance window (optional)
#   dynamic "maintenance_policy" {
#     for_each = var.maintenance_start_time == null ? [] : [1]
#     content {
#       recurring_window {
#         start_time = var.maintenance_start_time
#         end_time   = var.maintenance_end_time
#         recurrence = var.maintenance_recurrence
#       }
#     }
#   }
}

resource "google_container_node_pool" "pools" {
  for_each = var.node_pools

  name     = each.value.name
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.this.name

  node_count = each.value.node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb

    service_account = local.node_sa_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = merge(var.labels, try(each.value.labels, {}))

    tags = try(each.value.tags, [])

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}
