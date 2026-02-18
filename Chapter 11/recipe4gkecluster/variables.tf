variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "ch11-gke-cluster"
}

variable "node_count" {
  description = "Number of initial nodes"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Type of VM instances for nodes"
  type        = string
  default     = "e2-medium"
}