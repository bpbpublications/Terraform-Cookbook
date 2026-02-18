variable "region" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "account_name" {
  description = "Name for the Cosmos DB account"
  type        = string
  default     = "ch7cosmosdb"
}

variable "database_name" {
  description = "Name for the Cosmos DB SQL database"
  type        = string
  default     = "appdb"
}

variable "container_name" {
  description = "Name for the Cosmos DB SQL container"
  type        = string
  default     = "items"
}

variable "consistency_level" {
  description = "Consistency level for Cosmos DB account"
  type        = string
  default     = "Session"
}

variable "db_throughput" {
  description = "Throughput (RU/s) for the Cosmos DB SQL database"
  type        = number
  default     = 400
}

variable "partition_key_path" {
  description = "Partition key path for the Cosmos DB SQL container"
  type        = string
  default     = "/id"
}
