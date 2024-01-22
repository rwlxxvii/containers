#!/bin/bash

# Create an ECR repository to store the application:
export KANIKO_REPO=$(aws ecr create-repository \
 --repository-name kaniko \
 --query 'repository.repositoryUri' --output text)
 
export KANIKO_IMAGE="${KANIKO_REPO}:latest"

# Create an ECR repository to store the kaniko container image:
export KANIKO_BUILDER_REPO=$(aws ecr create-repository \
 --repository-name kaniko-builder \
 --query 'repository.repositoryUri' --output text)

export KANIKO_BUILDER_IMAGE="${KANIKO_BUILDER_REPO}:executor"

# Create an IAM role
ECS_TASK_ROLE=$(aws iam create-role \
  --role-name kaniko_ecs_role \
  --assume-role-policy-document file://ecs-trust-policy.json \
  --query 'Role.Arn' --output text)

# Export the AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
  --query 'Account' \
  --output text)

# Create a security group for ECS task:
KANIKO_SECURITY_GROUP=$(aws ec2 create-security-group \
  --description "SG for VPC Link" \
  --group-name KANIKO_SG \
  --vpc-id $KANIKO_VPC \
  --output text \
  --query 'GroupId')
