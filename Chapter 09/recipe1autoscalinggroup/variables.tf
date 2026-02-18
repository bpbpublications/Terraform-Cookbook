variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "min_size" {
  description = "Minimum Auto Scaling group size"
  type        = number
  default     = 2
}
variable "max_size" {
  description = "Maximum Auto Scaling group size"
  type        = number
  default     = 5
}
variable "desired_capacity" {
  description = "Desired initial capacity"
  type        = number
  default     = 2
}
variable "subnet_ids" {
  description = "List of subnet IDs for ASG"
  type        = list(string)
}
variable "cpu_threshold" {
  description = "CPU utilisation percent to trigger scale-out"
  type        = number
  default     = 70
}
