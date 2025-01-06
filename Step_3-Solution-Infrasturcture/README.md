# devops_skills_test_12-19-24

# Skills test #3: Infrastructure and deployment 

The requirements asked for infrastracture on AWS. This is Infrastructre as code and is not implmeneted fully. 


# The approach :
Whereas rk0 was brought up as an effective solution, without currenrtly having access to the desired cloud space I have written a terraform deployment module which will accomplish this task well. This will also show the versatility of docker as being able to be used in its own entity outside of an EC2 if such an architecture is desired. Or simply shift these containers back into an EC2 instance if the workload deamnds it. 

  - docker_registry_image section in infrastucture.tf will build desired image from dockerfile and push to registry on aws. 
  - aws_instace dictates the composition of the EC2 instance which will be running on AWS, this block also dictates the os to Rock linux 9. 
  - The aws_db_instance block dictates the MariaDB instance.  
  - aws_route53_record will designate the section needed for route 53 public dns setup 


# Achieving production security 
Upon being asked to increase environment security on production dealing with public access, I have added secure_deploymen.tf  . It features:



  - Load Balancer: Exposes port 443 for HTTPS traffic, forwarding requests to the EC2 instances on port 80. The load balancer provides an additional layer of security by terminating SSL connections, ensuring encrypted data transmission. It protects the VPC from scanning attacks and restricts unauthorized access through fine-grained control of incoming traffic. Additionally, the load balancer supports automatic health checks to ensure only healthy instances receive traffic, enhancing the reliability and availability of the application.

  - Secure S3 Bucket: Ensures private access to Puppet configuration files using IAM roles and policies. This configuration restricts access to authorized users and services only, minimizing exposure to unauthorized access or accidental data leaks. Access logs can be enabled for auditing and monitoring purposes, providing visibility into actions taken on the bucket.

  - IAM Policies: Enforces strict access segregation between database and EC2 resources. Policies ensure that only designated roles or groups have access to specific resources, limiting the blast radius in case of credential compromise. Puppet-created users are also scoped to access only the EC2 instances required for their tasks, adhering to the principle of least privilege.

  - Security Groups: Implements rules to control traffic between the load balancer, EC2 instances, and external clients. Ingress and egress rules ensure that only necessary ports (e.g., 443 for HTTPS and 80 for internal traffic) are open, significantly reducing the attack surface. Security groups are tailored to each resource type, ensuring that traffic flow adheres to the intended architecture and security policies.

  - Backup and Maintenance Enhancements: Database backups are retained for a specified period, ensuring data recovery in case of accidental deletion or corruption. Maintenance windows are defined to allow for controlled updates, minimizing disruptions to the application. These measures improve the system's resilience and maintainability in a production environment.

# Requirements: 

Terraform (any)

## Implementation steps :
  None without setup. Demonstration purposes only. After initial setup: 

  ```
  terraform init
  terraform plan 
  terraform deploy 
  ```



## Verification
None