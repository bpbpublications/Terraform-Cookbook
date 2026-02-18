variable "db_name_prefix" {
  description = "Prefix for the PostgreSQL server name (3–63 lowercase alphanumeric)"
  type        = string
}
variable "db_admin" {
  description = "Administrator login for PostgreSQL"
  type        = string
}
variable "db_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
}