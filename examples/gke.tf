module "gke" {
  source     = "../"
  project_id = "alert-flames-286515"

  name     = "cloud-projects-gke"
  location = "us-central1"

  # Hardcoded VPC and subnet (instead of referencing module outputs)
  network    = "cloud-projects-vpc"
  subnetwork = "prod-uscentral1-app"

  # Must match the secondary ranges defined in your subnet
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

