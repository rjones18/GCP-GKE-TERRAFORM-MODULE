# GCP-GKE-TERRAFORM-MODULE

Reusable Terraform module for provisioning a production-ready Google Kubernetes Engine (GKE) cluster on Google Cloud.

This module creates a regional GKE Standard cluster with support for private clusters, IP aliasing (VPC-native), multiple node pools, Workload Identity, and optional control plane access restrictions.

It is designed to integrate with a custom VPC module and follows common enterprise deployment patterns.

---

## Features

- Regional GKE Standard cluster
- Private cluster support
- Workload Identity enabled
- IP aliasing (VPC-native) using secondary subnet ranges
- Multiple configurable node pools
- Optional master authorized networks
- Shielded nodes enabled by default
- Configurable release channel (RAPID, REGULAR, STABLE)
- Reusable across dev, staging, and production environments

---

## Architecture Overview

This module provisions:

- One GKE cluster
- One or more managed node pools
- Optional dedicated node service account
- Private control plane (optional)
- IP allocation using existing subnet secondary ranges

The module assumes:

- A custom VPC already exists
- The target subnet contains secondary ranges for:
  - Pods
  - Services

---

## Usage Example

```hcl
module "gke" {
  source     = "./modules/gke"
  project_id = "alert-flames-286515"

  name     = "cloud-projects-gke"
  location = "us-central1"

  network    = "cloud-projects-vpc"
  subnetwork = "prod-uscentral1-app"

  pods_secondary_range_name     = "pods"
  services_secondary_range_name = "services"

  enable_private_cluster  = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"

  node_pools = {
    general = {
      name            = "general"
      node_count      = 1
      min_node_count  = 1
      max_node_count  = 3
      machine_type    = "e2-standard-4"
      disk_size_gb    = 100
      tags            = ["gke-node"]
    }
  }

  labels = {
    env     = "prod"
    project = "cloud-projects"
  }
}
