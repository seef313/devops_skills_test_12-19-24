# Define provider
provider "aws" {
  region = "us-east-1"
}

# Private s3 bucket to hold config 
resource "aws_s3_bucket" "puppet_config" {
  bucket = "puppet-config-bucket"
  acl    = "private"

  tags = {
    Name        = "PuppetConfigBucket"
    Environment = "Production"
  }
}

# Example config policy to control bucket access 
resource "aws_s3_bucket_policy" "puppet_config_policy" {
  bucket = aws_s3_bucket.puppet_config.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::account-id:role/role-name"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.puppet_config.arn}/*"
      }
    ]
  })
}

# Security Group for Load Balancer with necessary ports 
resource "aws_security_group" "lb_sg" {
  name        = "load-balancer-sg"
  description = "Allow HTTP and HTTPS access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-instance-sg"
  description = "Allow internal communication and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer to maintain production security 
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]

  enable_deletion_protection = true
}

# To supplment load balance VPC 
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-0123456789abcdef0"
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.rocky_ec2.id
  port             = 8080
}

# EC2 Instance with updated security
resource "aws_instance" "rocky_ec2" {
  ami           = data.aws_ami.rocky9.id
  instance_type = "t3.medium"
  key_name      = "your-key-pair"

  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker pull ${docker_registry_image.puppet_server.name}
              docker pull ${docker_registry_image.web_server.name}
              docker run -d --name puppet-server -p 8080:8080 ${docker_registry_image.puppet_server.name}
              docker run -d --name web-server -p 80:80 ${docker_registry_image.web_server.name}
              EOF

  tags = {
    Name = "AWS-EC2-SkillsTest"
  }
}

# IAM Policy for EC2 Access
resource "aws_iam_policy" "ec2_access" {
  name        = "EC2AccessPolicy"
  description = "Allow access to EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["ec2:Describe*", "ec2:StartInstances", "ec2:StopInstances"],
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for Database Access
resource "aws_iam_policy" "db_access" {
  name        = "DBAccessPolicy"
  description = "Allow access to RDS database"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["rds:Describe*", "rds:Connect"],
        Resource = "arn:aws:rds:region:account-id:db:mariadb"
      }
    ]
  })
}
