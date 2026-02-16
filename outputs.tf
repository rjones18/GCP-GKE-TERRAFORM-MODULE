output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_location" {
  value = google_container_cluster.this.location
}

output "endpoint" {
  value = google_container_cluster.this.endpoint
}

output "ca_certificate" {
  value     = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "node_pool_names" {
  value = [for _, np in google_container_node_pool.pools : np.name]
}

output "node_service_account_email" {
  value = local.node_sa_email
}
