aws_region       = "us-west-2"
instance_type    = "t3.micro"
min_size         = 2
max_size         = 5
desired_capacity = 2
subnet_ids       = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
cpu_threshold    = 70
