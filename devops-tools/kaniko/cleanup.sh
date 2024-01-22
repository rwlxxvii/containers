#!/bin/bash

# Remove the two ECR repos
aws ecr delete-repository --repository-name kaniko --force
aws ecr delete-repository --repository-name kaniko-builder --force

# Remove ECS Cluster
aws ecs delete-cluster --cluster kaniko-cluster

# Remove ECS Task Defintion
aws ecs deregister-task-definition --task-definition kaniko:1

# Remove CloudWatch Log Group
aws logs delete-log-group --log-group-name kaniko-builder

# Remove IAM Policy
aws iam delete-role-policy --role-name kaniko_ecs_role --policy-name kaniko
_push_policy

# Remove IAM Role
aws iam delete-role --role-name kaniko_ecs_role

# Remove security group
aws ec2 delete-security-group --group-id $KANIKO_SECURITY_GROUP
