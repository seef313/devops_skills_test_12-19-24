#Build docker containers and push to AWS EKS 
resource "docker_registry_image" "puppet-server"{
    name = aws-pupper-server
    build {
        context = "../Step_1-Solution-Puppet-WA/"
        dockerfile = "Dockerfile.puppetserver"
    }
}

resource "docker_registry_image" "web-server"{
    name = aws-web-server
    build {
        context = "../Step_2-Solution-MariaDB-WordPress-WA/"
        dockerfile = "Dockerfile.web01"
    }
}



resource "aws_db_instance" "mariadb" {
  allocated_storage    = 20                 
  storage_type         = "gp2"               
  engine               = "mariadb"           
  engine_version       = "10.2"              
  instance_class       = "db.t3.micro"      
  #database              = "marid_db"         
  username             = "admin"             
  password             = "securepassword123" 
  publicly_accessible  = false              
  skip_final_snapshot  = true                
  vpc_security_group_ids = ["sg-0123456789abcdef0"] 
  db_subnet_group_name = "my-subnet-group"

  # Backup and maintenance
  backup_retention_period = 7  
  backup_window           = "02:00-03:00" 
  maintenance_window      = "Mon:03:00-Mon:04:00" 
}

resource "aws_db_subnet_group" "example" {
  name       = "test"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"] 

  tags = {
    Name = "my-subnet-group"
  }
}



# Build and push Docker images to AWS ECR
resource "docker_registry_image" "puppet_server" {
  name = "aws-puppet-server"
  build {
    context    = "../Step_1-Solution-Puppet-WA/"
    dockerfile = "Dockerfile.puppetserver"
  }
}

resource "docker_registry_image" "web_server" {
  name = "aws-web-server"
  build {
    context    = "../Step_2-Solution-MariaDB-WordPress-WA/"
    dockerfile = "Dockerfile.web01"
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "docker-ec2-sg"
  description = "Allow access to EC2 for containers"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 Instance
resource "aws_instance" "rocky_ec2" {
  ami           = data.aws_ami.rocky9.id 
  instance_type = "t3.medium"            
  key_name      = ""        
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

# example route 53 

# Create a Route 53 DNS Record
resource "aws_route53_record" "dns_record" {
  zone_id = "var.route53_zone_id" 
  name    = "ec2.example.com"   
  type    = "A"

  ttl = 300

  records = [aws_instance.rocky_ec2.public_ip]
}

