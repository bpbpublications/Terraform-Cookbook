output "autoscaling_group_name" {
  description = "Name of the created Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}
