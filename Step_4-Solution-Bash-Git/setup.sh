#!/bin/bash

# Variables
AWS_REGION="us-east-1" 
ECR_REPOSITORY="test_repo" 
IMAGE_TAG="latest"
S3_BUCKET="some_config_bucket"
PUPPET_CONFIG_FILE="site.pp"
CONTAINER_NAME="web01"

# Authenticate with AWS ECR via password (or IAM credentials)
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.$AWS_REGION.amazonaws.com

# Pull the Docker image from ECR
echo "Pulling Docker image from ECR..."
docker pull <AWS_ACCOUNT_ID>.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG

# Create a local directory to download Puppet config
mkdir -p /tmp/puppet-config
cd /tmp/puppet-config

# Download the Puppet configuration file from S3
echo "Downloading Puppet configuration file from S3..."
aws s3 cp s3://$Example_config_bucket/$PUPPET_CONFIG_FILE . --region $AWS_REGION

# Optional: Parse sensitive details and store them in AWS Secrets Manager
# Extract password and public key (example placeholder)
PASSWORD=$(grep 'password' $PUPPET_CONFIG_FILE | awk '{print $NF}')
SSH_KEY=$(grep 'key' $PUPPET_CONFIG_FILE | awk '{print $NF}')

echo "Storing sensitive data in AWS Secrets Manager..."
aws secretsmanager create-secret --name puppet-config-password --secret-string "$PASSWORD" --region $AWS_REGION
aws secretsmanager create-secret --name puppet-config-ssh-key --secret-string "$SSH_KEY" --region $AWS_REGION

# Deploy the container with the Puppet config
echo "Deploying container using the pulled image..."
docker run -d --name $CONTAINER_NAME -v /tmp/puppet-config:/etc/puppet-config <AWS_ACCOUNT_ID>.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
