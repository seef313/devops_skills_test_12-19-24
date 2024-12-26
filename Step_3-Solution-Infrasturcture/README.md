# devops_skills_test_12-19-24

# Skills test #3: Infrastructure and deployment 

The requirements asked for infrastracture on AWS. This is Infrastructre as code and is not implmeneted fully. 


# The approach :
Whereas rk0 was brought up as an effective solution, without currenrtly having access to the desired cloud space I have written a terraform deployment module which will accomplish this task well. This will also show the versatility of docker as being able to be used in its own entity outside of an EC2 if such an architecture is desired. Or simply shift these containers back into an EC2 instance if the workload deamnds it. 

  - docker_registry_image section in infrastucture.tf will build desired image from dockerfile and push to registry on aws. 
  - aws_instace dictates the composition of the EC2 instance which will be running on AWS, this block also dictates the os to Rock linux 9. 
  - The aws_db_instance block dictates the MariaDB instance.  
  - aws_route53_record will designate the section needed for route 53 public dns setup 

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