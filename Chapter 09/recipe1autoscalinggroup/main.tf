data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners      = ["099720109477"]
  most_recent = true
}

resource "aws_launch_template" "app" {
  name_prefix   = "app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                    = "app-asg"
  min_size                = var.min_size
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  vpc_zone_identifier     = var.subnet_ids
  health_check_type       = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "app-server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_asg"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
