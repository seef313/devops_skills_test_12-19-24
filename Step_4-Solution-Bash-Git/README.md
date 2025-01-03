# devops_skills_test_12-19-24

# Skills test #4: Bash and git  

Bash and git mastery 

# The approach :
To demonstrate this step, we can look at setup.sh as an example bash script containing the setup of web01. From the previous exercise, assuming the terraform script execution created and stored this image in amazon container registry. This bash script will authenticate via IAM credentials, pull the image from the repository and deploy within the environment (assuming this script was executed in EC2)

The script will then get config files (site.pp) from an example bucket in s3, and parse its contents into AWS secrets manager for use in puppet. Container will then deploy with web01.  

